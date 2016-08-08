__global__ void histo_kernal(char *buffer, long size, int *histo )
{
     __shared__ int temp[256];
     temp[threadIdx.x] = 0;
     __syncthreads();

     int i = threadIdx.x + blockIdx.x * blockDim.x;
     int offset = blockDim.x * gridDim.x;
     int z;
     while (i < size)
     {
              z = buffer[i];
              atomicAdd( &temp[z], 1);
              i += offset;
     }
     __syncthreads();


    atomicAdd( &(histo[threadIdx.x]), temp[threadIdx.x] );
}


int main(int argc, char** args)
{

char args_two[10];
char args_four[10];
char *args_first_first;
//char *args_first_second;
//char *args_second_first;
//char *args_second_second;
if((strcmp(args[1], "-g") == 0) && (strcmp(args[3], "-t") == 0))
{
	strcpy(args_two, args[2]);
	args_first_first = strtok(args_two, "x");
	//args_first_second = strtok(NULL, "x");
	strcpy(args_four, args[4]);
	//args_second_first = strtok(args_four, "x");
	//args_second_second = strtok(NULL, "x");
	//printf("%c", array[0]);

}
else
{
printf("Incorrect argument format");
exit(EXIT_FAILURE);
}

// setup cuda timer
cudaEvent_t timer_start, timer_stop;
cudaEventCreate(&timer_start);
cudaEventCreate(&timer_stop);

// start cuda timer
cudaEventRecord(timer_start);


FILE *input_file;
char characters[256];
input_file = fopen(args[5], "r");
//unsigned int histo[256];

// set all histogram count values to 0
//int i;
//for(i = 0; i < 256; i++) {
//     histo[i] = 0;
//}


fseek(input_file, 0, SEEK_END); // seek to end of file
long size = ftell(input_file); // get current file pointer
//printf("%d",size);
fseek(input_file, 0, SEEK_SET);
char *host_buffer = (char *) malloc(size + 1);
fgets(host_buffer, size + 1, (FILE*)input_file);
fgets(host_buffer, 1, size + 1, (FILE*)input_file);
//printf(buff);

// create cuda variables and copy host memory to device memory
char *device_buffer;
int *device_histo;
cudaMalloc( (void**)&device_buffer, size + 1);
cudaMemcpy( device_buffer, host_buffer, size + 1, cudaMemcpyHostToDevice );
cudaMalloc( (void**)&device_histo,256 * sizeof( long ) );
cudaMemset( device_histo, 0, 256 * sizeof( int ) );

// executing kernal
int blocks = atoi(args_first_first);
histo_kernal<<<blocks*8, 1024, 1024*sizeof(int)>>>(device_buffer, size, device_histo);

// copy histogram back to host memory
unsigned int myhisto[256];
cudaMemcpy( myhisto, device_histo, 256 * sizeof(int), cudaMemcpyDeviceToHost );

// record cuda timing events
cudaEventRecord(timer_stop);
cudaEventSynchronize(timer_stop);
float ms;
cudaEventElapsedTime(&ms, timer_start, timer_stop);
printf("Time Elasped: %3.1f ms\n", ms );

// write histogram to text file
FILE *output_file;
output_file = fopen(args[6], "w");
fprintf(output_file, "Histogram\n");
int w;
for(w = 0; w < 256; w++) {
characters[w] = w;
fprintf(output_file,"%c = %d\n",characters[w], myhisto[w]);
printf("%c = %d\n",characters[w], myhisto[w]);
}

// clean up all cuda events, file pointers, etc
cudaEventDestroy(timer_start);
cudaEventDestroy(timer_start);
cudaFree(device_histo);
cudaFree(device_buffer);
free(host_buffer);
fclose(input_file);
fclose(output_file);





}
