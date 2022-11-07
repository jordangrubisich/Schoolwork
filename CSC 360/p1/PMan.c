/*
	CSC 360 Assignment 1
	Fall 2021
	Jordan Grubisich
	V00951272
*/

#include <unistd.h>     // fork(), execvp()
#include <stdio.h>      // printf(), scanf(), setbuf(), perror()
#include <stdlib.h>     // malloc()
#include <sys/types.h>  // pid_t 
#include <sys/wait.h>   // waitpid()
#include <sys/stat.h> //waitpid
#include <signal.h>     // kill(), SIGTERM, SIGKILL, SIGSTOP, SIGCONT
#include <errno.h>      // errno
#include <string.h>		//strmcp()
#include <readline/readline.h> // readline
#include <readline/history.h> // readline

//	||Defined Constants||


#define TRUE 1
#define FALSE 0
#define NUM_COMMANDS 6
#define MAX_INPUT 128


char* COM_LIST[] = {
	"bg",
	"bglist",
	"bgkill",
	"bgstop",
	"bgstart",
	"pstat",
};

//	||Typedefs and Global Process List Head||


typedef struct node {
	char* data;
	struct node* next;
} node;

typedef struct p_node {
	pid_t pid;
	char* name;
	int running;
	struct p_node* next;
} p_node;

struct stat sts;

p_node* headPnode = NULL;


//	||Linked List Functions||


//addnode:
//	inputs:
//		entry - name of command being added to commands list
//		head - pointer to the head of the commands list
//	function: creates and adds a node to the list of commands

node* addNode(char* entry, node* head){
	if(entry == NULL){
		return head;
	}

	node* new = (node*)malloc(sizeof(node));
	new->data = malloc(strlen(entry)+1);
	sprintf(new->data, "%s", entry);
	new->next = NULL;

	if(head == NULL){
		head = new;
		
	}
	else{
		node* temp;
		temp = head;
		for(temp = head; temp->next != NULL; temp=temp->next);
		temp->next = new;
	}
	return head;
}


//buildCList:
//	inputs:
//		input - the string of inputs received from the user
//		head - pointer to the head of the commands list
//	function: tokenizes the inputs and iteratively calls addNode

node* buildCList(char* input, node* head){
	char* token = strtok(input, " ");

	while(token != NULL){
		head = addNode(token,head);
		token = strtok(NULL," ");
	}
	return head;
}


//clearList:
//	inputs:
//		head - pointer to the head of the commands list
//	function: frees each node in the command list after command has been executed

void clearList(node* head){
	node* temp;

	while(head != NULL){
		temp = head;
		head = head->next;
		free(temp);
	}
}


//addProcess:
//	inputs:
//		pid - the pid of the process being added to the process list
//		procName - name of program associated with the given process
//	function: creates a process node and adds it to the list of processes

void addProcess(pid_t pid, char* procName){
	p_node* temp;

	p_node* new = (p_node*)malloc(sizeof(p_node));
	new->pid = pid;
	new->name = procName;
	new->running = TRUE;
	new->next = NULL;
	
	if(headPnode == NULL) {
		headPnode = new;

	} else {
		for(temp = headPnode; temp->next != NULL; temp = temp->next){
		}
		temp->next = new;
	}
}


//removeProcess:
//	inputs:
//		pid - the pid of the process to be removed
//	function: removes from the process list the node associated with the given pid

void removeProcess(pid_t pid){
	if(!exists(pid)){
		return;
	}

	p_node* temp;
	p_node* prev = NULL;

	for(temp = headPnode; temp != NULL; temp = temp->next){
		if(temp->pid == pid){
			if(headPnode == temp){
				headPnode = headPnode->next;
			} else {
				prev->next = temp->next;
			}
			free(temp);
			return;
		}
		prev = temp;
	}
}


//stopProcess:
//	inputs:
//		pid - the pid of the process to be stopped
//	function: changes the "running" attribute of the given process to false

void stopProcess(pid_t pid){
	if(!exists(pid)){
		return;
	}
	p_node* temp;
	for(temp = headPnode; temp != NULL; temp = temp->next){
		if(temp->pid == pid){
			temp->running = FALSE;
			return;
		}
	}
}


//startProcess:
//	inputs:
//		pid - the pid of the process to be started
//	function: changes the "running" attribute of the given process to true

void startProcess(pid_t pid){
	if(!exists(pid)){
		return;
	}
	p_node* temp;
	for(temp = headPnode; temp != NULL; temp = temp->next){
		if(temp->pid == pid){
			temp->running = TRUE;
			return;
		}
	}
}


//isRunning:
//	inputs:
//		pid - the pid of the process checked for "running" state
//	function: returns true if the given process is running, false if not

int isRunning(pid_t pid){
	if(!exists(pid)){
		return;
	}
	p_node* temp;
	for(temp = headPnode; temp != NULL; temp = temp->next){
		if(temp->pid == pid){
			return temp->running;
		}
	}
	return FALSE;
}


//exists:
//	inputs:
//		pid - the pid of the process checked for existence
//	function: returns true if the process exists in the process list, false if not

int exists(pid_t* pid){
	p_node* temp;
	for(temp = headPnode; temp != NULL; temp = temp->next){
		if(temp->pid == pid){
			return TRUE;
		}

	}
	return FALSE;
}


//	||Helper functions||


//numOfArgs:
//	inputs:
//		head - pointer to the head of the list of commands
//	function: returns the number of arguements in the given command list

int numOfArgs(node* head){
	if((head == NULL) || (head->next == NULL)){
		return 0;
	}

	node* temp;

	int i = 1;
	for(temp = head->next; temp->next != NULL; temp=temp->next){
		i++;
	}
	return i;
}


//validateCommand:
//	inputs:
//		command - name of the command to check for validity
//	function: checks the given command against the list of valid commands, returns true if valid, false if not

int validateCommand(char* command){
	int i;

	for(i=0;i<NUM_COMMANDS;i++){
		if(strcmp(command, COM_LIST[i])==0){
			return TRUE;
		}
	}
	printf("PMan: > %s:\tcommand not found\n",command);
	return FALSE;
}


//buildArgs:
//	inputs:
//		args - an empty array of strings to hold the given arguments
//		argList - the head of the list of command arguments
//	function: transfers the command in each node of the command list into the given array

void buildArgs(char** args, node* argList){
	int i=0;
	node* temp;
	
	for(temp = argList->next; temp != NULL; temp=temp->next){
		args[i] = temp->data;
		i++;
	}
	args[i]=NULL;
}


//exeCommand:
//	inputs:
//		command - a linked list holding the command and arguments to be run
//	function: determines and executes the desired "bg" command entered by the user

void exeCommand(node* command){
	char* prim = command->data;
	int numArgs = numOfArgs(command);
	char* args[numArgs+1];

	if(numArgs > 0){
		buildArgs(args,command);
	}

	if(strcmp(prim,"bg")==0){
		if(numArgs < 1){
			printf("PMan: > Invalid bg command\n");
		}
		else{
			bg(args);
		}
		
	}

	if(strcmp(prim,"bglist")==0){
		if(numArgs!=0){
			printf("invalid bglist arguments\n");
		} else {
			bglist();
		}
		
	}

	if(strcmp(prim,"bgkill")==0){
		if(numArgs != 1){
			printf("PMan: > Invalid bgkill arguments\n");
		}
		else{
			bgkill(args[0]);
		}
	}

	if(strcmp(prim,"bgstop")==0){
		if(numArgs != 1){
			printf("PMan: > Invalid bgstop arguments\n");
		}
		else{
			bgstop(args[0]);
		}
	}

	if(strcmp(prim,"bgstart")==0){
		if(numArgs != 1){
			printf("PMan: > Invalid bgstart arguments\n");
		}
		else{
			bgstart(args[0]);
		}
	}

	if(strcmp(prim,"pstat")==0){
		printf("pstat non functional :(\n");
	}
}


//cleanProcessList:
//	inputs:
//		none 
//	function: iterates through process list and removes any background processes that are no longer running

void cleanProcessList(){
	p_node* temp;

	for (temp = headPnode; temp != NULL; temp = temp->next){
		int stat;
		waitpid(temp->pid, &stat, WNOHANG);
		if(kill(temp->pid,0)==-1){
			removeProcess(temp->pid);
		}
	}
}


//	||"bg" commands||


//bg:
//	inputs:
//		argv - pointer to the array containing the program name and its corresponding arguments
//	function: creates child process to execute the given program in the background

void bg(char **argv){
	
	pid_t pid;
	pid = fork();

	if(pid == 0){ //child process

		//tries to run execvp with and without "./" (for shell commands)
		if(execvp(argv[0], &argv[0]) < 0){
			char* prefix ="./";
			char* suffix = argv[0];
			char progName[sizeof(argv[0]+3)];
			snprintf(progName, sizeof(progName),"%s%s",prefix,suffix);

			argv[0] = progName;

			if(execvp(argv[0], &argv[0]) < 0){
				perror("Error on execvp");
			}
			
		}
		exit(EXIT_SUCCESS);
	}
	else if(pid > 0) { //parent process
		addProcess(pid,argv[0]);
		sleep(1);
		
	}
	else {
		perror("fork failed");
		exit(EXIT_FAILURE);
	}
}


//bgkill:
//	inputs:
//		pid - a string containing the pid of the process to kill
//	function: kills the process associated with the given pid

void bgkill(char* pid){
	
	if(!exists(atoi(pid))){
		printf("Error: process %s does not exist\n",pid);
		return;
	}

	int success = kill(atoi(pid),15);

	if(success == -1){
		printf("Error: unable to kill process %s\n",pid);
	} else {
		printf("Killed process: %s\n",pid);
		removeProcess(atoi(pid));
		sleep(1);
	}
}


//bgstop:
//	inputs:
//		pid - a string containing the pid of the process to stop
//	function: stops the process associated with the given pid

void bgstop(char* pid){

	if(!exists(atoi(pid))){
		printf("Error: process %s does not exist\n",pid);
		return;
	}
	if(!isRunning(atoi(pid))){
		printf("Error: process %s is already stopped\n",pid);
		return;
	}

	int success = kill(atoi(pid),19);

	if(success == -1){
		printf("Error: unable to stop process %s\n",pid);
	} else {
		stopProcess(atoi(pid));
		printf("Stopped process: %s\n",pid);
		sleep(1);
	}
}


//bgstop:
//	inputs:
//		pid - a string containing the pid of the process to stop
//	function: stops the process associated with the given pid

void bgstart(char* pid){

	if(!exists(atoi(pid))){
		printf("Error: process %s does not exist\n",pid);
		return;
	}
	if(isRunning(atoi(pid))){
		printf("Error: process %s is already running\n",pid);
		return;
	}

	int success = kill(atoi(pid),18);

	if(success == -1){
		printf("Error: unable to start process %s\n",pid);
	} else {
		startProcess(atoi(pid));
		printf("Started process: %s\n",pid);
		sleep(1);
	}
}


//bglist:
//	inputs:
//		none
//	function: produces a list of processes running in the background, their file path, their running state and the total number of processes

void bglist(){
	int total = 0;
	p_node* temp;

	for(temp = headPnode; temp != NULL; temp = temp->next){
		total++;

		char* state = "";
		if(!temp->running){
			state = "|STOPPED|";
		};

		//builds the name of the directory where the current process path is located
		char* procName = temp->name;
		char* pre = "/proc/";
		char* suf = "/exe";
		char path[64];
		snprintf(path, sizeof(path),"%s%d%s",pre,temp->pid,suf);

		//retrieves the path of the current pid
		char location[64];
		size_t pathLength = readlink(path, location, sizeof(location)-1);
		location[pathLength] = 0;

		printf("%d:\t %s %s\n",temp->pid,location,state);
	}
	printf("Total background jobs:\t%d\n",total);

}


//	||main||


int main(){

	while(1){	
		char* input = readline("PMan: > ");
		if(strcmp(input,"")!=0){
			node* cList = NULL;

			cList = buildCList(input, cList);

			int valid = validateCommand(cList->data);

			if(valid){
				exeCommand(cList);
				clearList(cList);
			}

		else{
			clearList(cList);
		}
		}
		cleanProcessList();
	}
	return 0;
}
