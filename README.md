# fillin-puzzle

The objective of this program is to solve fillin crossword puzzles by logic programming and
Prolog.

## Fillin Puzzles
A fillin puzzle (sometimes called a fill-it-in) is like a crossword puzzle, except that instead of
being given obscure clues telling which words go where, you are given a list of all the words
to place in the puzzle, but not told where they go.
The puzzle consists of a grid of squares, most of which are empty, into which letters or
digits are to be written, but some of which are filled in solid, and are not to be written in.
You are also given a list of words or multi-digit numbers to place in the puzzle. Henceforth
we shall discuss the puzzles in terms of words and letters, but keep in mind that they can be
numbers and digits, too.

You must place each word in the word list exactly once in the puzzle, either left-to-right or
top-to-bottom, filling a maximal sequence of empty squares. Also, every maximal sequence of non-solid
squares that is more than one square long must have one word from the word list written in it.
Many words cross one another, so many of the letters in a horizontal word will also be a letter in
a vertical word. For a properly constructed fillin puzzle, there will be only one way to fill 
in the words (in some cases, the puzzle is symmetrical around a diagonal axis, in which case
there will be two symmetrical solutions).

### Example
An example of 7 by 7 fillin puzzle, taken from the Wikipedia page for fillin puzzles. In this 
example, one word is already written into the puzzle, but this is not required.

##___##  
##____#  
D___#__  
A______  
G_#____  
#____##  
##___##  

And the solution,

##EVO##  
##DENS#  
DAIS#IO  
ARTICLE  
GI#CLOD  
#DOLE##  
##REF##  

The word list for this puzzle is,
GI  
IO  
ON  
OR  
DAG  
EVO  
OED  
REF  
ARID  
CLEF  
CLOD  
DAIS  
DENS  
DOLE  
EDIT  
SILO  
ARTICLE  
VESICLE  

## The Program
You will write Prolog code to solve fillin puzzles. The program should supply a predicate
main(PuzzleFile, WordlistFile, SolutionFile) that reads in the puzzle file whose name is 
PuzzleFile and the word list file whose name is WordlistFile, solve the puzzle, and print out 
the result to the file SolutionFile.

The PuzzleFile will contain a number of lines each with the same number of characters,
to form a rectangle. The characters in this file should all be either an underline character (_)
indicating a fill-able square, a hash character (#) indicating a solid, non-fill-able square, or
a letter or digit, indicating a pre-filled square.

The output SolutionFile must have the same format (except that it should be filled, so it should
not contain underlines).

The WordlistFile is simply a text file with one word per line.
