#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <locale>
#define N 1000
void cpu_SLAU(double* A, double* X)
{
    double d = 0;
    for (int i = 0; i < N; i++)
    {
        d = A[i * (N + 1) + i];
        for (int j=N;j>=i;j--)
        {
            A[i * (N + 1) + j] /= d;
        }
        for (int j=i+1;j<N;j++)
        {
            d = A[j * (N + 1) + i];
            for (int k = N; k >= i; k--)
                A[j * (N + 1) + k] -= d * A[i * (N + 1) + k];
        }

    }
    for (int k = N - 1; k >= 0; k--) {
        d = 0;
        for (int j = k + 1; j < N; j++)
            d += A[k * (N + 1) + j] * X[j];
        X[k] = (A[k * (N + 1) + N] - d) / A[k * (N + 1) + k];
    }
}
int main()
{
    int i, k, j, p = 0;
    double d;
    double* A;
    double* X;
    A = (double*)calloc(N * (N + 1), sizeof(double*));
    X = (double*)calloc(N, sizeof(double));
    srand(time(NULL));
    for (i = 0; i < N; i++) {
        for (j = 0; j < N + 1; j++) {
            if (i == j) A[i * (N + 1) + j] = 3;
            else A[i * (N + 1) + j] = 2;

        }
    }
    printf("\n");
    cpu_SLAU(A, X);


    printf("SLAU:\n");

    for (i = 0; i < N; i++)
        printf("X%d = %.2f  \n", i, X[i] );
    return 0;
}