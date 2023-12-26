.data
mat:
    .float -6.0, 4.0, 6.0, -8.0, -3.0, -50.0
    .float -4.0, 3.0, 4.0, -4.0, -9.0, 11.0
    .float -3.0, -1.0, -1.0, -6.0, 2.0, -29.0
    .float -2.0, -4.0, 6.0, -5.0, 7.0, -53.0
    .float -7.0, -9.0, -10.0, 5.0, 9.0, 12.0

X:
    .float 0.0, 0.0, 0.0, 0.0, 0.0

str_no_solution:
        .string "No solution exists\n"
str_infinite_solution:
        .string "Infinitely many solutions exist\n"
str_newline:
        .string "\n"

.text
    .globl main
main:

    # Initialize variables
    li x1, 5             # x1: Number of Rows (m) = 5
    li x2, 6             # x2: Number of Columns (n) = 6
    li x3, 4             # x3: Offset = 4
    la x4, mat           # x4: Load the base address of mat
    la x5, X             # x5: Load the base address of X
    addi x6, x1, -1      # x6: m-1
    addi x7, x2, -1      # x7: n-1

    li x8, 0             # x8: initialize i = 0

    # Partial Pivoting
outer_loop:
    bge x8, x6, outer_loop_done      # Exit outer loop if i >= m - 1

    addi x9, x8, 1       # x9: j = i + 1

pivoting_loop:
    bge x9, x1, pivoting_loop_done    # Exit inner loop if j >= m 

    # Getting mat[i][i]
    mul x24, x8, x2               # i*6
    add x24, x24, x8              # (i*6)+i
    mul x24, x24, x3              # offset * ((i*6)+i) 
    add x24, x24, x4              # B.A. + offset * ((i*6)+i)
    flw f1, 0(x24)                # Load mat[i][i]: 0(x24) into f1 : Diagonal element

    # Getting mat[j][i]
    mul x25, x9, x2               # j*6
    add x25, x25, x8              # (j*6)+i
    mul x25, x25, x3              # offset * ((j*6)+i) 
    add x25, x25, x4              # B.A. + offset * ((j*6)+i)
    flw f2, 0(x25)                # Load mat[j][i]: 0(x25) into f2 : Element below diagonal
   
    # Comparison mat[i][i] <= mat[j][i]
    fabs.s  f1, f1                # Calculate absolute value of diagonal element
    fabs.s  f2, f2                # Calculate absolute value of element below diagonal

    li x13, 0                     # x13: k = 0

    mv x12, x0                    # x12 = 0
    flt.s x12, f1, f2             # if f1 <= f2, set x12 to 1
    bne x12, x0, swap_loop        # if x12 != 0 then branch to swap_loop

    flt.s x12, f2, f1             # if f2 <= f1, set x12 to 1
    bne x12, x0, no_swap          # if x12 != 0 then branch to no_swap
    
swap_loop:
    bge x13, x2, swap_loop_done   # Exit inner loop if k >= n

    # Storing mat[i][k]
    mul x14, x8, x2               # i*6
    add x14, x14, x13             # (i*6)+k
    mul x14, x14,x3               # offset * ((i*6)+k) 
    add x14, x14,x4               # B.A. + offset * ((i*6)+k)
    flw f3, 0(x14)                # Load mat[i][k]: 0(x14) into f3

    # Storing mat[j][k]
    mul x15, x9, x2               # j*6
    add x15, x15, x13             # (j*6)+k
    mul x15, x15,x3               # offset * ((j*6)+k) 
    add x15, x15,x4               # B.A. + offset * ((j*6)+k)
    flw f4, 0(x15)                # Load mat[j][k]: 0(x15) into f4

    # Swaping here
    fsw f4, 0(x14)                # store value from f4 to 0(x14)
    fsw f3, 0(x15)                # store value from f3 to 0(x15)

    addi x13, x13, 1              # Increment k
    j swap_loop

swap_loop_done:
    addi x9, x9, 1                # Increment j
    j pivoting_loop

no_swap:
    addi x9, x9, 1                # Increment j
    j pivoting_loop

pivoting_loop_done:
    addi x9, x8, 1                # x9: j = i + 1
    j gauss_elimination           # jump to gauss_elemination

gauss_elimination:
    bge x9, x1, gauss_elimination_done     # Exit loop if j >= m

    # Getting mat[i][i]
    mul x16, x8, x2               # i*6
    add x16, x16, x8              # (i*6)+i
    mul x16,x16,x3                # offset * ((i*6)+1) 
    add x16,x16,x4                # B.A. + offset * ((i*6)+i)
    flw f5, 0(x16)                # Load mat[i][i]: 0(x16) into f5 : Diagonal element

    # Calculating mat[j][i]
    mul x17, x9, x2               # j*6
    add x17, x17, x8              # (j*6)+i
    mul x17,x17,x3                # offset * ((j*6)+i) 
    add x17,x17,x4                # B.A. + offset * ((j*6)+i)
    flw f6, 0(x17)                # Load mat[j][i]: 0(x17) into f6 : Element below diagonal

    # Check if diagonal element is zero
    mv x12, x0
    feq.s x12, f5, f0                        # if f5 = 0, put 1 into x12
    bne x12, x0, diagonal_zero               # if x12 != 0 then, branch to elemination_done

    feq.s x12, f5, f0                        # if f5 = 0, put 1 into x12
    beq x12, x0, diagonal_not_zero           # if x12 = 0 then, branch to elemination_done

diagonal_zero:
    addi x9, x9, 1                # Increment j
    j gauss_elimination

diagonal_not_zero:
    li x18, 0                     # x18: k = 0
    j elimination_loop

elimination_loop:
    # Perform elimination
    bge x18, x2, elimination_loop_done       # Exit inner loop if k >= n

    # Calculate term
    fdiv.s f7, f6, f5             # f7 = term = mat[j][i] / mat[i][i]

    # Locating mat[j][k]
    mul x19, x9, x2               # j*6
    add x19, x19, x18             # (j*6)+k
    mul x19, x19, x3              # offset * ((j*6)+k) 
    add x19, x19, x4              # B.A. + offset * ((j*6)+k)
    flw f8, 0(x19)                # Load mat[j][k]: 0(x19) into f8

    # Locating mat[i][k]
    mul x20, x8, x2               # i*6
    add x20, x20, x18             # (i*6)+k
    mul x20, x20, x3              # offset * ((i*6)+k) 
    add x20, x20, x4              # B.A. + offset * ((i*6)+k)
    flw f9, 0(x20)                # Load mat[i][k]: 0(x20) into f9

    fmul.s f10, f7, f9            # f10: term * mat[i][k]
    fsub.s f8, f8, f10            # f8 = f8 - f10

    # Update value in matrix
    fsw f8, 0(x19)

    addi x18, x18, 1              # increment k
    j elimination_loop

elimination_loop_done:
    addi x9, x9, 1                # increment j
    j gauss_elimination

gauss_elimination_done:
    addi x8, x8, 1                # increment i
    j outer_loop

outer_loop_done:
    li x21, 0                     # load i = 0
    j back_substitution

back_substitution:
    blt x8, x0, back_substitution_done       # Exit loop if i < 0

    # Getting mat[i][i]
    mul x24, x8, x2              # i*6
    add x24, x24, x8             # (i*6)+i
    mul x24, x24, x3             # offset * ((i*6)+i) 
    add x24, x24, x4             # B.A. + offset * ((i*6)+i)
    flw f10, 0(x24)              # Load mat[i][i]: 0(x24) into f10

    # Getting mat[i][n-1]
    mul x25, x8, x2              # i*6
    add x25, x25, x7             # (i*6)+(n-1)
    mul x25, x25, x3             # offset * ((i*6)+(n-1)) 
    add x25, x25, x4             # B.A. + offset * ((i*6)+(n-1))
    flw f11, 0(x25)              # Load mat[i][n-1]: 0(x25) into f11

    # Locating X[i]
    mul x12, x8, x3              # i * offset
    add x12, x5, x12             # B.A + (i * offset)
    
    # Storing into X[i]
    fsw f11, 0(x12)              # Updating the value in x[i] = mat[i][n-1]
    flw f12, 0(x12)              # Load X[i] into f12

    addi x9, x8, 1               # j = i + 1
    j j_loop

j_loop:
    bge x9, x7, mat_zero         # Exit loop if j >= n - 1

    # Getting mat[i][j]
    mul x13, x8, x2              # i*6
    add x13, x13, x9             # (i*6)+j
    mul x13, x13, x3             # offset * ((i*6)+j) 
    add x13, x13, x4             # B.A. + offset * ((i*6)+j)
    flw f13, 0(x13)              # Load mat[i][j]: 0(x13) into f13

    # Getting X[j]
    mul x14, x9, x3              # j * offset
    add x14, x5, x14             # B.A + (j * offset)

    flw f14, 0(x14)              # Load X[j]: 0(x14) into f14

    fmul.s f15, f13, f14         # f15: mat[i][j] * x[j]
    fsub.s f12, f12, f15         # f16: x[i] - mat[i][j] * x[j]

    # Storing into X[i]
    fsw f12, 0(x12)              # Store the value of X[i]

    addi x9, x9, 1               # Increment j
    j j_loop

mat_zero:
    mv x15, x0
    feq.s x15, f10, f0           # if f10 = 0, x15 = 1 else x15 = 0
    beqz x15, decrement_i        # if x15 = 0, branch to decrement_i
    
    mv x15, x0
    feq.s x15, f10, f0           # if f10 = 0, x15 = 1 else x15 = 0
    bnez x15, if_x_zero          # if x15 != 0, branch to if_x_zero

decrement_i:
    # Update x[i] = x[i] / mat[i][i]
    fdiv.s f17, f12, f10         # f17: x[i] / mat[i][i]
    fsw f17, 0(x12)              # Update value inside X[i]

    addi x8, x8, -1              # decrement i
    j back_substitution

if_x_zero:
    # Check if X[i] == 0 or X[i] != 0
    flw f18 ,0(x12)                            # Fetching X[i] into f18

    mv x16, x0
    feq.s x16, f18, f0                      # if f12 = 0, x16 = 1 else x16 = 0  
    beqz x16, print_no_solution             # if x16 = 0, branch to No_solution
    
    mv x16, x0
    feq.s x16, f18, f0                      # if f12 = 0, x16 = 1 else x16 = 0  
    bnez x16, print_infinite_solution       # if x16 != 0, branch Infifnite_solution 

back_substitution_done:
    li x31, 0                       # i = 0
    j print_unique_solution

print_infinite_solution:
    addi a0,x0,4
    la a1, str_infinite_solution   # Load address of the string
    ecall                           # Print the string
    j exit_program

print_no_solution:
    addi a0,x0,4
    la a1, str_no_solution    # Load address of the string    # Load mat[i][n-1]: 0(x25) into f11

    # Locating X[i]
    mul x12, x8, x3 
    ecall                     # Print the string
    j exit_program

print_unique_solution:
    bge x31, x7, exit_program  # if i >= n - 1, exit_program

    mv x30, x31                # Load i to x30
    mul x30, x30, x3           # i * offset
    add x30, x30, x5           # B.A. + (i * offset)

    addi a0, x0, 34            # Load a0 with a constant value (34)
    
    lw a1, 0(x30)              # Load the value at address x30 into a1
    ecall                      # Perform a system call (specific syscall action unclear)

    # Load a0 with the address of a newline character ('\n')
    addi a0, x0, 4
    la a1, str_newline         # Load a1 with the length of the string (1)
    ecall                      # Print the newline character

    addi x31, x31, 1           # Increment i by 1
    j print_unique_solution    # Jump back to the beginning of the loop (print_uniquesol)

exit_program:
    li a1, 10    # System call code for program exit
    ecall        # Invoke the system call