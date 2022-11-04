
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <device_functions.h>
#include <cuda.h>
#include <stdio.h>
#include <time.h>
#include <math.h>
#include <locale>
#include <Windows.h>
#define N 5
#define Block_size 1


__global__ void Str_SLAU(double* A,double *B)
{
    int k = blockIdx.x * blockDim.x + threadIdx.x ;
    double d = 0;

   if (k<N){
        for (int j = k + 1; j < N; j++) {
            d = (double)A[j*N + k ] / A[k*N +  k];
            for (int i = k; i < N; i++)
                A[j*N + i] -= d * A[k*N + i];
            B[j] -= d * B[k];
        }
    }
}
__global__ void rev_SLAU(double* A, double* B, double* X)
{
    int k = blockIdx.x * blockDim.x + threadIdx.x;
    double d = 0;
    if (k < N) {
        for (int j = k + 1; j < N; j++) {
            d += A[k*N + j] * X[j];
        }
        X[k] = (B[k] - d) / A[k*N + k];
    }
}
int main() {
    setlocale(LC_ALL, "Russian");
    int i, k, j, p = 0;
    double d;
    double* A_d;
    double* B_d;
    double* X_d;
    double* HostA;
    double* HostB;
    double* HostX1;
    double* HostX2;
    HostA = (double*)calloc(N * N, sizeof(double*));
    HostB = (double*)calloc(N, sizeof(double));
    HostX1 = (double*)calloc(N, sizeof(double));
    HostX2 = (double*)calloc(N, sizeof(double));
    srand(time(NULL));
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            HostA[i*N + j ] = double(rand() - rand()) / 2020;
        }
        HostB[i] = double(rand() - rand()) / 2020;
    }
    cudaMalloc((void**)&A_d, N * N * sizeof(double));
    cudaMalloc((void**)&B_d, N * sizeof(double));
    cudaMalloc((void**)&X_d, N * sizeof(double));
    cudaMemcpy(A_d, HostA, N * N * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, HostB, N * sizeof(double), cudaMemcpyHostToDevice);
    dim3 threads(Block_size, Block_size);
    dim3 blocks(N / threads.x, N / threads.y);
    Str_SLAU<<< 1, N*N >>>(A_d, B_d);
    cudaThreadSynchronize();/
    cudaMemcpy(HostX2, X_d, N * sizeof(double), cudaMemcpyDeviceToHost);
    cudaMemcpy(HostA, A_d, N*N * sizeof(double), cudaMemcpyDeviceToHost);
    cudaMemcpy(HostB, B_d, N * sizeof(double), cudaMemcpyDeviceToHost);
    for (int i = 0; i < N; i++) {
        printf("|");
        for (int j = 0; j < N; j++)
            printf(" %f   ", HostA[i * N + j]);
        printf(" %f ", HostB[i]);
        printf("| \n");
    }
    for (i = 0; i < N; i++)
        printf("X%d = %f  // %f \n", i, HostX1[i], HostX2[i]);
}
