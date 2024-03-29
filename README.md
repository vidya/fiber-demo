fiber-demo
==========

Use fibers to solve a programming problem

This program is an attempt to solve the problem specified at:

    https://github.com/ePublishing/ruby-developer-challenges

Thank you, Robert James Kaes (rjkaes)!


Problem:

A colleague of yours has a terrible habit of misspelling their words. The odd
thing is that there is a consistent pattern such that it is always the last
two letters that get messed up.

You've been challenged with the task to clean up the mess. Using a spell
checker will catch most of the mistakes, but not all. We need to find all the
possibilities for the remaining typos and verify that they are syntactically
correct.

Given the provided dictionary text file (wordsEn.txt), return a list
of word pairs whereby swapping the last two letters of the word results in
another valid word. (e.g [coal, cola], [minute, minuet])

Requirements:
 - Word length must be greater than 2 characters
 - In the case where swapping the last two letters results in the same word, the
   word should be omitted (e.g. [bee, bee])
 - Your method should output an array of "pairs", where each pair is a 2 element
   array (e.g. [[coal, cola], [minute, minuet]])

Your solution will be benchmarked.

Example:

If word list is:

apple
bee
coal
coke
cola
dog
waist
waits
zebra

Your output should be:

[["coal", "cola"], ["waist", "waits"]]

* The order of the pairs and elements w/in those pairs is not important (doesn't have to be alphabetical)

Please check the provided unit tests for example usage and make sure to use
them for verifying your solution!