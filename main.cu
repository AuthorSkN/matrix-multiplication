#include "iostream"
#include <fstream>
#include <string>

#define BLOCK_SIZE  16          // submatrix size
#define N           1024        // matrix size is N*N

__global__ void matMult ( float * a, float * b, int n, float * c )
{
    int   bx  = blockIdx.x;     // block index
    int   by  = blockIdx.y;
    int   tx  = threadIdx.x;        // thread index
    int   ty  = threadIdx.y;
    float sum = 0.0f;           // computed subelement
    int   ia  = n * BLOCK_SIZE * by + n * ty;   // a [i][0]
    int   ib  = BLOCK_SIZE * bx + tx;

    // Multiply the two matrices together;
    for ( int k = 0; k < n; k++ )
        sum += a [ia + k] * b [ib + k*n];

    // Write the block sub-matrix to global memory;
    // each thread writes one element
    int ic = n * BLOCK_SIZE * by + BLOCK_SIZE * bx;

    c [ic + n * ty + tx] = sum;
}

void write_data_to_file(std::string messge, float * a){
    std::ofstream myfile;
    myfile.open ("test_data.txt", std::fstream::app);
    myfile << messge + "\n";
    for ( int i = 0; i < N; i++ )
        for ( int j = 0; j < N; j++ )
        {
            int	k = N*i + j;
            myfile << a [k];
        }
    myfile << "\n";
    myfile.close();
}

void clear_file(){
    std::ofstream ofs;
    ofs.open("test_data.txt", std::ofstream::out | std::ofstream::trunc);
    ofs.close();
}

int main ( int argc, char *  argv [] )
{
    clear_file();
    int numBytes = N * N * sizeof ( float );

    // allocate host memory
    float * a = new float [N*N];
    float * b = new float [N*N];
    float * c = new float [N*N];

    for ( int i = 0; i < N; i++ )
        for ( int j = 0; j < N; j++ )
        {
            int	k = N*i + j;

            a [k] = 0.0f;
            b [k] = 1.0f;
        }
    write_data_to_file("First matrix", a);
    write_data_to_file("Second matrix", b);

    // allocate device memory
    float * adev = NULL;
    float * bdev = NULL;
    float * cdev = NULL;

    cudaMalloc ( (void**)&adev, numBytes );
    cudaMalloc ( (void**)&bdev, numBytes );
    cudaMalloc ( (void**)&cdev, numBytes );

    // set kernel launch configuration
    dim3 threads ( BLOCK_SIZE, BLOCK_SIZE );
    dim3 blocks  ( N / threads.x, N / threads.y);

    // create cuda event handles
    cudaEvent_t start, stop;
    float gpuTime = 0.0f;

    cudaEventCreate ( &start );
    cudaEventCreate ( &stop );

    // asynchronously issue work to the GPU (all to stream 0)
    cudaEventRecord ( start, 0 );
    cudaMemcpy      ( adev, a, numBytes, cudaMemcpyHostToDevice );
    cudaMemcpy      ( bdev, b, numBytes, cudaMemcpyHostToDevice );

    matMult<<<blocks, threads>>> ( adev, bdev, N, cdev );

    cudaMemcpy      ( c, cdev, numBytes, cudaMemcpyDeviceToHost );
    cudaEventRecord ( stop, 0 );

    cudaEventSynchronize ( stop );
    cudaEventElapsedTime ( &gpuTime, start, stop );

    // print the cpu and gpu times
    printf("time spent executing by the GPU: %.2f millseconds, results were saved to test_data.txt\n", gpuTime );
    write_data_to_file("Result matrix", c);

    // release resources
    cudaEventDestroy ( start );
    cudaEventDestroy ( stop  );
    cudaFree         ( adev  );
    cudaFree         ( bdev  );
    cudaFree         ( cdev  );

    delete a;
    delete b;
    delete c;

    return 0;
}