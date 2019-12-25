# Matrix multiplication
## The goal
Calculate matrix multiplication with cuda c++ compiler
## Prerequisites
* installed cuda c++ compiler
### Current PC Configuration
* graphics processor - GeForce GTX 950
* nvcc compiler version - release 10.1
## Run program
1. open project folder
1. compile cu file
    ```
    nvcc main.cu
    ```
1. run compiled program
    ```
    ./a.out
    ```
## Input parameters
There're no specific input parameters. Two initial matrix creates in code right after program was ran.
## Results
To mulpiply two square matrix with size 1024 x 1024 test machine took in average 29,50 milleseconds