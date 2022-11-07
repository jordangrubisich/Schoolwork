//CSC360 - P2
//Jordan Grubisich
//V00951272

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/time.h>

//--- Constants ---
#define MAX_INPUT 1024
#define MAX_CUST 256

//--- Typedefs ---
typedef struct customer{
    int id;
    int class;
    int arrival_time;
    int service_time;
} customer;

//--- Global Variables ---
struct timeval initialTime;
int clerks[5];
customer customers[MAX_CUST];
customer* businessQ[MAX_CUST];
customer* economyQ[MAX_CUST];
int businessQLen = 0;
int economyQLen = 0;
double totalBusinessWait;
double totalEconomyWait;
pthread_t customerThreads[MAX_CUST];
pthread_cond_t free_clerk;
pthread_mutex_t busMutex;
pthread_mutex_t ecoMutex;
pthread_mutex_t clerkMutex;
pthread_mutex_t custMutex;
pthread_mutex_t timeMutex;


//--- Helper Fuctions ---

//standardize:
//  Inputs: a string
//  Function: replaces ',' and ':' characters with '.'
void standardize(char str[]){
    int i = 0;
    while(str[i] != '\0'){

        if(str[i] == ','){
            str[i] = '.';
        } else if(str[i] == ':'){
            str[i] = '.';
        }
        i++;

    }

}

//getTimeDiff:
//  Inputs: None
//  Function: calculates and returns the difference between the current simulation time and the initial simulation time
double getTimeDiff(){
	
	struct timeval currtime;
	double cur_secs, init_secs;
	
	
	init_secs = (initialTime.tv_sec + (double) initialTime.tv_usec / 1000000);
	
	
	gettimeofday(&currtime, NULL);
	cur_secs = (currtime.tv_sec + (double) currtime.tv_usec / 1000000);
	return cur_secs - init_secs;
}

//readFile:
//  Inputs: path - file path to read, inputContents - 2D array for the lines of the file to be stored in
//  Function: opens and reads a txt file containing the customer information. Stores each line of file into inputContents
int readFile(char* path, char inputContents[MAX_INPUT][MAX_INPUT]){
    FILE *fp = fopen(path, "r");
    if(fp != NULL){
        int i = 0;
        while(fgets(inputContents[i], MAX_INPUT, fp)){
            i++;
        }
        fclose(fp);
        return 1;
    }
    return 0;
}

//inputToList:
//  Inputs: inputContents - 2D array with the strings representation of a customer stored at each index, totalCustomers - the total number of customers in the array
//  Function: converts the array of strings into customer structs and stores them into a global array of customers
void inputToList(char inputContents[MAX_INPUT][MAX_INPUT], int totalCustomers){
    int i;
    for(i = 1; i <= totalCustomers; i++){
        int newCust[4];
        int k = 0;
        standardize(inputContents[i]);
        char* tok = strtok(inputContents[i], ".");

        while(tok != NULL){
            newCust[k] = atoi(tok);
            tok = strtok(NULL, ".");
            k++;
        }

        customer c = {
            newCust[0],
            newCust[1],
            newCust[2],
            newCust[3]

        };
        

        customers[i-1] = c;

    }
}

//enqueue:
//  Inputs: c - a customer struct to be stored into the corresponding queue
//  Function: takes the customer and enters them into either the business or economy queue based on customer class
void enqueue(customer* c){
    if(c->class == 0){ //economy class
        pthread_mutex_lock(&ecoMutex);
        economyQ[economyQLen] = c;
        economyQLen++;
        printf("A customer enters a queue: the queue ID %1d, and length of the queue %2d. \n", 0, economyQLen);
        pthread_mutex_unlock(&ecoMutex);
    } else if(c->class == 1){ //business class
        pthread_mutex_lock(&busMutex);
        businessQ[businessQLen] = c;
        businessQLen++;
        printf("A customer enters a queue: the queue ID %1d, and length of the queue %2d. \n", 1, businessQLen);
        pthread_mutex_unlock(&busMutex);
    }
}

//dequeue:
//  Inputs: c - a customer struct to be removed from the corresponding queue
//  Function: takes a customer and removes them from the queue in which thay are waiting
void dequeue(customer* c){
    int i = 0;
    int class = c->class;
    if(class == 0){ // economy class  
        pthread_mutex_lock(&ecoMutex);  
        while(i < economyQLen-1){
            economyQ[i] = economyQ[i+1];
            i++;
        } 
        economyQLen--;
        pthread_mutex_unlock(&ecoMutex);
    } else if(class == 1){ // business class
        pthread_mutex_lock(&busMutex);  
        while(i < businessQLen-1){
            businessQ[i] = businessQ[i+1];
            i++;
        }
        businessQLen--;
        pthread_mutex_unlock(&busMutex);
    }

}

//freeClerks:
//  Inputs: None
//  Function: parses the global array of clerks, counts and returns to total number of clerks who are free to help customers
int freeClerks(){
    pthread_mutex_lock(&clerkMutex);
    int i, j;
    j=0;
    for(i=0; i<5;i++){
        j+= clerks[i];
    }
    pthread_mutex_unlock(&clerkMutex);
    return j;
}

//peekQueue:
//  Inputs: c - a customer to compare with the front of their corresponding queue
//  Function: checks the queue which c belongs to, returns 1 if c is at the front and 0 if not
int peekQueue(customer* c){
    int match = 0;
    if(c->class == 0){
        pthread_mutex_lock(&ecoMutex);
        if(c->id == economyQ[0]->id){
            match = 1;
        }
        pthread_mutex_unlock(&ecoMutex);
    } else if (c->class == 1){
        pthread_mutex_lock(&busMutex);
        if(c->id == businessQ[0]->id){
            match = 1;
        }
        pthread_mutex_unlock(&busMutex);
    }
    return match;
}

//addWaitTime:
//  Inputs: c - a customer to indicate which wait time to increment
//  Function: adds a customers queue wait time to the total corresponding wait time for their class
void addWaitTime(customer* c){
    int class = c->class;
    int arr = c->arrival_time;
    double elapsed;
    elapsed = getTimeDiff();

    pthread_mutex_lock(&timeMutex);
    if(class == 0){
        totalEconomyWait += (arr - elapsed);
    }
    if(class == 0){
        totalBusinessWait += (arr - elapsed);
    }
    pthread_mutex_unlock(&timeMutex);
}

//--- Thread Functions ---

//customerEntry:
//  Inputs: cust - a customer to be simulated by the thread
//  Function: simulates a customer / clerks in the airline check-in system model.
void* customerEntry(void* cust){
    struct customer* c = (customer*)cust;
    
    //simulate time before arrival
    usleep(c->arrival_time*100000);
    printf("A customer arrives: customer ID %2d. \n",c->id);
    
    //add customer to their corresponding queue
    enqueue(c);
    
    //simulate waiting for an available clerk
    while((c->class == 0 && businessQLen >= freeClerks()) ||freeClerks() == 0 || !peekQueue(c)){
        pthread_cond_wait(&free_clerk, &custMutex);
    }
    pthread_mutex_unlock(&custMutex);

    //gather information about the clerk that is serving this customer
    pthread_mutex_lock(&clerkMutex);
    int servingClerk = 0;
    for(int i = 0; i<5; i++){
        if(clerks[i]){
            servingClerk = i+1;
            clerks[i] = 0;
            break;
        }
    }
    pthread_mutex_unlock(&clerkMutex);

    //simulate customer leaving queue and recording their wait time in queue
    dequeue(c);
    addWaitTime(c);
    
    //simulate the time taken for the clerk to serve the customer
    printf("A clerk starts serving a customer: start time %.2f, the customer ID %2d, the clerk ID %1d. \n",getTimeDiff(),c->id,servingClerk);
    usleep(c->service_time*100000);
    printf("A clerk finishes serving a customer: end time %.2f, the customer ID %2d, the clerk ID %1d. \n",getTimeDiff(),c->id,servingClerk);

    //indicate that the clerk is free again after serving customer
    pthread_mutex_lock(&clerkMutex);
    clerks[servingClerk-1] = 1;
    pthread_mutex_unlock(&clerkMutex);

    //if customers still exist in the queue, signal to them that a clerk is now free
    if(businessQLen > 0 || economyQLen > 0){
        pthread_cond_broadcast(&free_clerk);
        pthread_mutex_unlock(&custMutex);
    }
    return 0;

}


//--- Main ---

int main(int argc, char* argv[]){
    int totalCustomers = 0;
    int totalBusiness = 0;
    int totalEconomy = 0;
    

    //check for proper command line syntax
    if(argc!=2){
        printf("Invalid Number of arguments\n");
        exit(1);
    }

    //read input file into array of input data
    char inputContents[MAX_INPUT][MAX_INPUT];
    int success = readFile(argv[1],inputContents);

    if(success == 0){
        printf("Failed to read input file\n");
        exit(1);
    }

    //convert input data array into array of customer structs
    totalCustomers = atoi(inputContents[0]);
    inputToList(inputContents, totalCustomers);


    //initialize mutex and convar variables
    if(pthread_mutex_init(&busMutex, NULL) != 0){
        printf("Failed to initialize business queue mutex\n");
        exit(1);
    }
     if(pthread_mutex_init(&ecoMutex, NULL) != 0){
        printf("Failed to initialize economy queue mutex\n");
        exit(1);
    }
    if(pthread_mutex_init(&clerkMutex, NULL) != 0){
        printf("Failed to initialize clerk mutex\n");
        exit(1);
    }
    if(pthread_mutex_init(&custMutex, NULL) != 0){
        printf("Failed to initialize customer mutex\n");
        exit(1);
    }
    if(pthread_mutex_init(&timeMutex, NULL) != 0){
        printf("Failed to initialize time mutex\n");
        exit(1);
    }
    if(pthread_cond_init(&free_clerk, NULL) != 0){
        printf("Failed to initialize conditional variable\n");
        exit(1);
    }

    //initialize pthread attrubute and detatchstate
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

    //collect the number of customer in each class
    int i;
    customer* tempCust;
    for(i=0; i < totalCustomers; i++){
        tempCust = &customers[i];
        if(tempCust->class == 0){
            totalEconomy++;
        } else if (tempCust->class == 1){
            totalBusiness++;
        }
    }
    
    //record the starting time of the simulation
    gettimeofday(&initialTime, NULL);

    //initialize all clerks to free
    for(i=0; i < 5; i++){
        clerks[i]=1;
    }
    
    //create a thread for each customer in the array of customers
    for(i=0; i < totalCustomers; i++){
        pthread_create(&customerThreads[i], &attr, customerEntry, (void*)&customers[i]);
    }

    //wait for all customer threads to finish before continuing
    for(i=0; i < totalCustomers; i++){
        pthread_join(customerThreads[i],NULL);
    }

    //calculate and print the average wait time for each class as well as the average wait time for all customers
    double avgBusWait;
    double avgEcoWait;
    double avgTotWait;

    avgBusWait = totalBusinessWait / totalBusiness;
    avgEcoWait = totalEconomyWait / totalEconomy;
    avgTotWait = (totalBusinessWait + totalEconomyWait) / totalCustomers;

    printf("The average waiting time for all customers in the system is: %.2f seconds. \n",avgTotWait);
    if(totalBusiness!= 0) printf("The average waiting time for all business-class customers is: %.2f seconds. \n",avgBusWait);
    if(totalEconomy!= 0) printf("The average waiting time for all economy-class customers is: %.2f seconds. \n",avgEcoWait);
}