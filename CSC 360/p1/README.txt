CSC 360 Assignment 1
Fall 2021
Jordan Grubisich
V00951272

Contents:

Included in the zipped folder is:
1.The c program PMan.c (process manager) 
2.The test c files inf.c and args.c 
3.The MakeFile to compile these programs 
4.This README.

Compiling and executing:

1.To compile execute the command 'make' from the terminal. This will compile PMan.c as well as the test files inf.c and args.c.
2.To run PMan, execute the command './PMan' from the terminal.


Supported commands of PMan:
1. bg <cmd>: start program <cmd> in the background
2. bglist: display a list of all the programs currently executing in the background as well as the total number of running processes
3. bgkill <pid>: terminate process <pid>
4. bgstop <pid>: temporarily stop process <pid>
5. bgstart <pid>: restart process <pid> which has been previously stopped
6. pstat <pid>: currently non-functional

Testers:
To run the test file inf within PMan execute the command bg inf <tag> <interval>. The tag is the string to print infinitly
and the interval is the delay in seconds between prints.

To run the test file args within PMan execute the command bg args <args>.

Exiting:
To exit PMan press 'ctrl+c' from any point in the program.


