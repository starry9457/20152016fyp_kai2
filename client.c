#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/time.h>

#define RECV_BUFSIZ 65536   //size of receive buffer

//Print usage information
void usage(char *program);

int main(int argc, char **argv)
{
    char server[16] = {'\0'};   //IP address (e.g. 192.168.101.101)
    int port;   //TCP port number
    int data_size;  //Request data size (KB)
    struct timeval tv_start;    //Start time (after three way handshake)
    struct timeval tv_end;  //End time
    int sockfd; //Socket
    struct sockaddr_in servaddr;    //Server address (IP:Port)
    int len;    //Read length
    char buf[RECV_BUFSIZ] = {'\0'};  //Receive buffer
    int write_count = 0;    //total number of bytes to write
    int read_count = 0; //total number of bytes received
    unsigned long fct;  //Flow Completion Time
    int seq_count = 1;
    FILE *fp = NULL;
    char filename[255] = {'\0'};
    unsigned long totaltime = 0;
    unsigned long totalbyte = 0;

    if (argc < 4)
    {
        usage(argv[0]);
        return 0;
    }

    if (argc >= 5)
    {
        seq_count = atoi(argv[4]);
    }

    if (argc >= 6)
    {
        strncpy(filename, argv[5], sizeof(filename));
    }

    //Get server address
    strncpy(server, argv[1], 15);
    //Get TCP port: char* to int
    port = atoi(argv[2]);
    //Get data_size: char* to int
    data_size = atoi(argv[3]);

    if (strlen(filename) != 0)
    {
        // printf("Will output to %s\n", filename);
        fp = fopen(filename, "w");
    }

    // printf("filename: %s\n", filename);

    //Init server address
    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = inet_addr(server);
    servaddr.sin_port = htons(port);

    //Init socket
    if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("Socket error\n");
        return 0;
    }

    //Establish connection
    if (connect(sockfd, (struct sockaddr *)&servaddr, sizeof(struct sockaddr)) < 0)
    {
        printf("Can not connect to %s\n", server);
        return 0;
    }
    for (int i = 0; i < seq_count; i++) {
        printf("Client running seq: %d. Total seq: %d\n", i, seq_count);

        //Get start time after connection establishment
        gettimeofday(&tv_start, NULL);

        //Send request
        // printf("Sending data when i = %d\n", i);
        // printf("Seq %d: Sending message '%s' to %d\n", i, argv[3],sockfd);
        write_count = strlen(argv[3]);  // argv[3] ---> data_size
        while (write_count > 0)
           write_count -= send(sockfd, argv[3], write_count, 0);

        //Receive data
        while(1)
        {
            // printf("Seq %d: Receiving message from %d\n", i, sockfd);
            // printf("Receiving data when i = %d\n", i);
            len = recv(sockfd, buf, RECV_BUFSIZ, 0);
            // printf("Seq %d: Received message: '%s', length: %d\n", i, buf, len);
            read_count += len;

            if ( (len <= 0) || (read_count >= data_size * 1024) )
                break;
        }
        
        //Get end time after receiving all of the data
        gettimeofday(&tv_end, NULL);

/*
        //Close connection
        printf("Seq %d: Connection closed\n", i);
        close(sockfd);
*/

        //Calculate time interval (unit: microsecond)
        fct = (tv_end.tv_sec - tv_start.tv_sec) * 1000000 + tv_end.tv_usec - tv_start.tv_usec;

        if (data_size * 1024 == read_count)
            printf("From %s: %d KB %lu us\n", server, data_size, fct);
        else
            printf("We receive %d (of %d) bytes.\n", read_count, data_size * 1024);

        totaltime += fct;
        totalbyte += read_count;
        
        if (fp != NULL)
        {
            fprintf(fp, "%d, %lu\n", i, fct);
        }
        bzero(buf, RECV_BUFSIZ);
        read_count = 0;
        write_count = 0;
    }
    unsigned long avgtime = totaltime / seq_count;
    //Close connection
    printf("Total data transfered: %lu bytes. Total time: %lu us (average time: %lu us).\n", totalbyte, totaltime, avgtime);
    if (fp != NULL)
    {
        fprintf(fp, "Total data transfered: %lu bytes. Total time: %lu us (average time: %lu us).\n", totalbyte, totaltime, avgtime);
        fclose(fp);
    }
    printf("Client Connection closed\n");
    close(sockfd);
    return 0;
}


void usage(char *program)
{
    printf("%s [server IP] [server port] [request flow size(KB)] [counts(optional)] [output(optional)]\n", program);
}