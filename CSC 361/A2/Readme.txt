Jordan Grubisich
V00951272
CSC361 - Assignment 2
README.txt

To Run: excecute python3 TCPstats.py <capfilename.cap> from this directory

NOTE: this directory must also contain packet_struct.py (provided in the .tar archive) and the .cap file you wish to pass as an argument to TCPstats.py
	sample-capture-file.cap has also been provided in the .tar archive to test functionality

Functionality:

TCPstats.py will take the provided capfile and:
	A)Print to the terminal the total number of TCP connections found in the capfile
	B)Print a list of all connections found in the cap file including information regarding each connection
	C)Print the number of completed connections, reset connections and incomplete connections
	D)Print the min, max and mean of: 	1) time duration of all connections
							2) RTT of all packets
							3) number of packets of each connection
							4) receive window size of all packets

Known Issues:
Currently the min, max and mean RTT times in part D) are outputting irregular values