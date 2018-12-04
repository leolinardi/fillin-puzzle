/*--------------------------------------------------------------------*/
/* Module : proj2
 * Author : Leonardo Linardi <llinardi@student.unimelb.edu.au>

   COMP30020 - Declarative Programming - Project 2
   This module implements a strategy to solve a fillin puzzle while given
   a list of words.

   Fillin puzzle (sometimes called a fill-it-in) is like a crossword
   puzzle, except that instead being given obscure clues telling which
   words go where, a list of all the words to be placed in the puzzle
   is given, but not where they go. The puzzle consists of a grid of
   squares, which can either be fill-able (represented by an underline, '_',
   to be filled with a letter/digit), a non-fill-able solid (represented by
   a hash, '#') or pre-filled (with a letter/digit).
   Each word in the list can only be placed exactly once in the puzzle,
   either left-to-right or top-to-bottom.

   The strategy is that a list of "slots" (a maximal horizontal or vertical
   sequence of fill-able and pre-filled squares) is going to be constructed,
   where each slot is a list of Prolog variables representing one square in
   the puzzle. It is also guaranteed that the same variable is used for the
   same square, whether it appears in a horizontal or vertical slot.

   To increase performance, as each word is selected to be placed in a slot,
   the word is unified immediately with that slot, so when the unification
   fails, all further permutations involving that word in that slot can be
   discarded. Thus, reducing the number of permutations of the list of words
   that could fit in the slot list.

   To further enhance performance, before choosing a word to be placed in
   the slots, for each slot, the number of words that can match that slot is
   counted. And (one of) the slot(s) with the fewest matching words to fill
   is selected. Thus, minimises the search space.
 */
:- 	ensure_loaded(library(clpfd)).
/*--------------------------------------------------------------------*/

% Reads in the puzzle 'PuzzleFile', the wordlist 'WordlistFile' from a file,
% solves and prints out the solved puzzle 'SolutionFile' to a file.
main(PuzzleFile, WordlistFile, SolutionFile) :-
	read_file(PuzzleFile, Puzzle),
	read_file(WordlistFile, Wordlist),
	valid_puzzle(Puzzle),
	solve_puzzle(Puzzle, Wordlist, Solved),
	print_puzzle(SolutionFile, Solved).

/*--------------------------------------------------------------------*/
% Takes a file 'Filename', reads and returns the 'Content' of it.
read_file(Filename, Content) :-
	open(Filename, read, Stream),
	read_lines(Stream, Content),
	close(Stream).

% Processes all of the lines of a file from 'Stream', returns 'Content', a
% list of lists of characters, with each list represents a line.
read_lines(Stream, Content) :-
	read_line(Stream, Line, Last),
	(   Last = true
	->  (   Line = []
	    ->  Content = []
	    ;   Content = [Line]
	    )
	;  Content = [Line|Content1],
	    read_lines(Stream, Content1)
	).

% Processes a line of a file from 'Stream', returns 'Line', a list of
% characters from a line, and a flag 'Last', indicating whether it's the
% last line of the file.
read_line(Stream, Line, Last) :-
	get_char(Stream, Char),
	(   Char = end_of_file
	->  Line = [],
	    Last = true
	;   Char = '\n'
	->  Line = [],
	    Last = false
	;   Line = [Char|Line1],
	    read_line(Stream, Line1, Last)
	).

/*--------------------------------------------------------------------*/
% Prints the solved puzzle 'Puzzle', in the form of a list of lists of
% characters, to the file 'SolutionFile'.
print_puzzle(SolutionFile, Puzzle) :-
	open(SolutionFile, write, Stream),
	maplist(print_row(Stream), Puzzle),
	close(Stream).

% Prints per 'Row' of the puzzle to 'Stream'.
print_row(Stream, Row) :-
	maplist(put_puzzle_char(Stream), Row),
	nl(Stream).

% Prints per 'Char' of a row of the puzzle to 'Stream'.
put_puzzle_char(Stream, Char) :-
	(   var(Char)
	->  put_char(Stream, '_')
	;   put_char(Stream, Char)
	).

/*--------------------------------------------------------------------*/
% Checks if a puzzle is valid, whether it has the same length for every row.
valid_puzzle([]).
valid_puzzle([Row|Rows]) :-
	maplist(samelength(Row), Rows).

/*--------------------------------------------------------------------*/
% Given an unsolved puzzle 'Puzzle' and a list of words 'WordList' to fill in,
% this predicate solves and returns the solved puzzle 'Solved'. 'Puzzle',
% 'WordList' and 'Solved' are in the form of a lists of lists of characters.
solve_puzzle(Puzzle, WordList, Solved) :-
	%quicksort(WordList, SortedWords),
	fill_with_variables(Puzzle, VariablePuzzle),
	make_slots(VariablePuzzle, [], PartialSlots),
	transpose(VariablePuzzle, TranspPuzzle),
	make_slots(TranspPuzzle, PartialSlots, AllSlots),
	transpose(TranspPuzzle, Solved), !,
	insert_words(AllSlots, WordList).

/*--------------------------------------------------------------------*/
% Fills the unsolved puzzle with Prolog variables, by converting each
% fill-able square to a Prolog variable.
fill_with_variables([], []).
fill_with_variables([Row|Puzzle], VariablePuzzle) :-
	fill_per_row(Row, VariableRow),
	VariablePuzzle = [VariableRow|RemainingPuzzle],
	fill_with_variables(Puzzle, RemainingPuzzle).

% Processes per puzzle row, converting all of the fill-able squares to a
% Prolog variable.
fill_per_row([],[]).
fill_per_row(['_'|Lines], [_|VariableLines]) :-
	fill_per_row(Lines, VariableLines).
fill_per_row([X|Lines], [X|VariableLines]) :-
	fill_per_row(Lines, VariableLines).

/*--------------------------------------------------------------------*/
% Given an unsolved puzzle filled with Prolog variables, a list of slots are
% created to represent the maximal sequence of a fill-able and pre-filled
% squares.
make_slots([], Slots, Slots) :- !.
make_slots([VRow|VariablePuzzle], Acc, Slots) :-
	slots_per_row(VRow, OneRowSlot),
	append(Acc, OneRowSlot, Acc1),
	make_slots(VariablePuzzle, Acc1, Slots).

% Creates slot(s) for each row of the unsolved puzzle, with an accumulator.
slots_per_row(VRow, OneRowSlot) :-
	slots_per_row(VRow, [], [], OneRowSlot).

% Processes each character ('Char') of a row of the puzzle, and create
% slot(s) from a sequence of it. A valid word has a minimum of 2 characters.
slots_per_row([], [], OneRowSlot, OneRowSlot).
slots_per_row([], CurrentSlot, Acc, OneRowSlot) :-
	( length(CurrentSlot, Len), Len >= 2 ->
		append(Acc, [CurrentSlot], NewAcc),
		slots_per_row([], [], NewAcc, OneRowSlot)
	; slots_per_row([], [], Acc, OneRowSlot)
	).
slots_per_row([Char|VariableRow], CurrentSlot, Acc, OneRowSlot) :-
	( Char=='#'->
		length(CurrentSlot, Len),
		( Len >= 2 ->
	    	append(Acc, [CurrentSlot], NewAcc),
	    	slots_per_row(VariableRow, [], NewAcc, OneRowSlot)
	  	; slots_per_row(VariableRow, [], Acc, OneRowSlot)
		)
	; append(CurrentSlot, [Char], NewSlot),
   	  slots_per_row(VariableRow, NewSlot, Acc, OneRowSlot)
	).

/*--------------------------------------------------------------------*/
% From the list of 'Slots',
% - on each slot, find the number of words from 'WordList' that can match
%   (by the help of find_matching_words/3)
% - select the slot that has the fewest matching words (by keysort/2)
% - pick a word from the list of matching words and try to bind that word
%   to the slot (by member/2)
% - if the word successfully binds, remove that word from 'WordList' and
%   remove that slot from the slot list 'Slots' (by select/3)
insert_words(_, []).
insert_words(Slots, WordList) :-
	find_matching_words(Slots, WordList, NumMatchSPairs),
	keysort(NumMatchSPairs, [_-FewestMatchSlot|_]),
	member(FewestMatchSlot, WordList),
	select(FewestMatchSlot, WordList, NewWordList),
	select(FewestMatchSlot, Slots, NewSlots),
	insert_words(NewSlots, NewWordList).

/*--------------------------------------------------------------------*/
% Finds the number of words that can match each slot, with an accumulator.
find_matching_words(Slots, WordList, NumMatchSPairs) :-
	find_matching_words(Slots, WordList, [], NumMatchSPairs).

% For each slot, a 'NumMatch'-'S' pair is formed, where
% 'NumMatch': the number of words that can match/correctly fills the slot
% 'S': the slot itself, that is going to be binded with a word
find_matching_words([], _, Acc, Acc).
find_matching_words([S|Slots], WordList, Acc, NumMatchSPairs) :-
	bagof(S, member(S, WordList), MatchingWords),
	length(MatchingWords, NumMatch),
	append(Acc, [NumMatch-S], NewAcc),
	find_matching_words(Slots, WordList, NewAcc, NumMatchSPairs).

/*--------------------------------------------------------------------*/
