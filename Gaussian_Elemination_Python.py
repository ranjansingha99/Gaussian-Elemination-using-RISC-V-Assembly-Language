import numpy as np
import random

def generate_random_matrix(rows, cols):
    return np.random.rand(rows, cols) * 20 - 10  # Generates random values between -10 and 10

def gaussian_elimination(matrix):
    m, n = matrix.shape
    
    for i in range(m):
        # Partial pivoting
        max_row = i
        for j in range(i + 1, m):
            if abs(matrix[j, i]) > abs(matrix[max_row, i]):
                max_row = j
        matrix[i], matrix[max_row] = matrix[max_row].copy(), matrix[i].copy()
        
        # Make the diagonal elements 1
        diag_element = matrix[i, i]
        for j in range(i, n):
            matrix[i, j] /= diag_element
        
        # Eliminate other rows
        for j in range(m):
            if j != i:
                factor = matrix[j, i]
                for k in range(i, n):
                    matrix[j, k] -= factor * matrix[i, k]
    
    # Extract the solutions
    solutions = matrix[:, n-1].copy()
    
    return solutions

# Generate a random augmented matrix with 5 rows and 6 columns
random_matrix = generate_random_matrix(5, 6)

# Print the randomly generated matrix
print("\nRandom Matrix:")
print(random_matrix)

try:
    # Calculate the solutions using Gaussian elimination
    solutions = gaussian_elimination(random_matrix)
    
    # Print the solutions with precision 12.16
    print("\nSolution:")
    for i, solution in enumerate(solutions):
        print(f'x{i+1} = {solution:.16f}')
except ZeroDivisionError:
    print("No unique solution exists due to division by zero.")
except Exception as e:
    print(f"An error occurred: {str(e)}")
