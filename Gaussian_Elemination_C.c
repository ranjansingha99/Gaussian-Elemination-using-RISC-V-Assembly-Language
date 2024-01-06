#include <stdio.h>
#include <math.h>

int main()
{
    int m = 5 , n= 6;

    float a[5][6] = {{-6.0, 4.0, 6.0, -8.0, -3.0, -50.0},
                    {-4.0, 3.0, 4.0, -4.0, -9.0, 11.0},
                    {-3.0, -1.0, -1.0, -6.0, 2.0, -29.0},
                    {-2.0, -4.0, 6.0, -5.0, 7.0, -53.0},
                    {-7.0, -9.0, -10.0, 5.0, 9.0, 12.0}};
                    
    float x[5] = {0.0, 0.0, 0.0, 0.0, 0.0};

    int i, j, k;

    // Partial Pivoting
    for (i = 0; i < m - 1; i++)
    {
        for (j = i + 1; j < m; j++)
        {
            // If diagonal element(absolute vallue) is smaller than any of the terms below it
            if (fabs(a[i][i]) <= fabs(a[j][i]))
            {
                // Swap the rows
                for (k = 0; k < n; k++)
                {
                    float temp;
                    temp = a[i][k];
                    a[i][k] = a[j][k];
                    a[j][k] = temp;
                }
            }
        }

        // Begin Gauss Elimination
        for (j = i + 1; j < m; j++)
        {
            if (a[i][i] == 0){
                break;
            }
            float term = a[j][i] / a[i][i];
            for (k = 0; k < n; k++)
            {
                a[j][k] = a[j][k] - term * a[i][k];
            }
        }
    } 

    // Print row_echelon form
        for(int i = 0; i < m ; i++){
            printf("\n");
            for(int j = 0; j < n ; j++){
                printf("%f ", a[i][j]);
            }
        }
        printf("\n");

    // Begin Back-substitution
    for (i = m - 1; i >= 0; i--)
    {
        x[i] = a[i][n - 1];
        
        for (j = i + 1; j < n - 1; j++)
        {
            x[i] = x[i] - a[i][j] * x[j];
        }

        if(a[i][i] == 0){
            if(x[i] == 0){
                printf("Infinite solution exists\n");
                return -1;
            }
            else if(x[i] != 0){
                printf("No solution exists\n");
                return -1;
            }
        }
        x[i] = x[i] / a[i][i];
    }

    // Printing Result
    for (int i = 0; i < n - 1; i++){
        printf("%f\n", x[i]);
    }
    
}
