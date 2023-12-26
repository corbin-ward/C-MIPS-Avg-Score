.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
endl: .asciiz "\n"
space:.asciiz " "


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi	$sp, $sp -4
	sw	$ra, 0($sp)
	li	$v0, 4 
	la	$a0, str0 
	syscall 
	li	$v0, 5		# Read the number of scores from user
	syscall
	move	$s0, $v0	# $s0 = numScores
	move	$t0, $0
	la	$s1, orig	# $s1 = orig
	la	$s2, sorted	# $s2 = sorted
loop_in:
	li	$v0, 4 
	la	$a0, str1 
	syscall 
	sll	$t1, $t0, 2
	add	$t1, $t1, $s1
	li	$v0, 5		# Read elements from user
	syscall
	sw	$v0, 0($t1)
	addi	$t0, $t0, 1
	bne	$t0, $s0, loop_in
	
	move	$a0, $s0
	jal	selSort		# Call selSort to perform selection sort in original array
	
	li	$v0, 4 
	la	$a0, str2 
	syscall
	move	$a0, $s1	# More efficient than la $a0, orig
	move	$a1, $s0
	jal	printArray	# Print original scores
	li	$v0, 4 
	la	$a0, str3 
	syscall 
	move	$a0, $s2	# More efficient than la $a0, sorted
	jal	printArray	# Print sorted scores
	
	li	$v0, 4 
	la	$a0, str4 
	syscall 
	li	$v0, 5		# Read the number of (lowest) scores to drop
	syscall
	move	$a1, $v0
	sub	$a1, $s0, $a1	# numScores - drop
	move	$a0, $s2
	jal	calcSum		# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it
	slt	$t0, $zero, $a1
	bne	$t0, $zero, compute_avg
	li	$v0, 4 
	la	$a0, str5 
	syscall			# Print str5
	li	$v0, 1
	li	$a0, 0
	syscall			# Print 0
	j	end_main
compute_avg:
	div	$t1, $v0, $a1
	li	$v0, 4 
	la	$a0, str5 
	syscall			# Print str5
	li	$v0, 1
	addi	$a0, $t1, 0
	syscall			# Print average
end_main:
	lw 	$ra, 0($sp)
	addi	$sp, $sp 4
	li	$v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here
	addi	$sp, $sp, -4	# Reserve space on stack
	sw	$a0, 0($sp)	# Store $a0
	mul	$t0, $a1, 4	# $t0 stores the total number of bytes in the array
	li	$t1, 0		# i = 0
	move	$t4, $a0	# load array into $t4
loop_in_1:	
	slt	$t2, $t1, $t0
	beq	$t2, $zero, return_1	# Branches to return_2 if i >= array size
	lw	$a0, 0($sp)	# Resets $a0 to the array space
	lw	$t3, 0($t4)	# Loads $t3 with the array value
	li	$v0, 1
	addi	$a0, $t3, 0
	syscall			# Prints the array value at i
	li	$v0, 4
	la	$a0, space
	syscall			# Prints a space
	addi	$t4, $t4, 4	# Increments the array pointer by 4 bytes
	addi	$t1, $t1, 4	# Increments i by 4 bytes
	j	loop_in_1	# Jumps to start of loop
return_1:	
	li	$v0, 4
	la	$a0, endl
	syscall			# Print endl
	lw	$a0, 0($sp)	# Restore $a0
	addi	$sp, $sp, 4	# Release space on stack
	jr $ra
	
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here
	mul	$t0, $a0, 4	# $t0 stores the total number of bytes in the array
	li	$t1, 0		# i = 0
	move	$t4, $s1	# Stores pointer to orig array in $t4
	move	$t5, $s2	# Stores pointer to sorted array in $t5
loop_in_2:	# Copy orig to sorted
	slt	$t2, $t1, $t0
	beq	$t2, $zero, loop_out_2	# Branches to loop_out_2 if i >= array size
	lw	$t3, 0($t4)	# Loads $t3 with the orig array value
	sw	$t3, 0($t5)	# Stores sorted with orig array value
	addi	$t4, $t4, 4	# Increments the orig array pointer by 4 bytes
	addi	$t5, $t5, 4	# Increments the sorted array pointer by 4 bytes
	addi	$t1, $t1, 4	# Increments i by 4 bytes
	j	loop_in_2	# Jumps to start of loop
loop_out_2:
	addi	$t1, $t0, -4	# Subtract four bytes from total bytes
	li	$t2, 0		# i = 0
loop_in_3:	# Sort
	slt	$t3, $t2, $t1
	beq	$t3, $zero, return_2	# Branches to return_2 if i >= array size - 1
	addi	$t4, $t2, 0		# maxIndex = i
	addi	$t5, $t2, 4		# j = i + 1 (4 bytes)
loop_in_4:
	slt	$t3, $t5, $t0
	beq	$t3, $zero, loop_out_4	# Branches to loop_out_4 if j >= array size
	add	$t6, $s2, $t5	
	lw	$t6, 0($t6)	# $t6 = sorted[j]
	add	$t7, $s2, $t4
	lw	$t7, 0($t7)	# $t7 = sorted[maxIndex]
	slt	$t8, $t7, $t6	
	beq	$t8, $zero, increment	# Branch if(sorted[maxIndex] >= sorted[j])
	addi	$t4, $t5, 0	# maxIndex = j
increment:
	addi	$t5, $t5, 4	# j++
	j 	loop_in_4
loop_out_4:
	add	$t7, $s2, $t4
	lw	$t5, 0($t7)	# temp = sorted[maxIndex]
	add	$t6, $s2, $t2
	lw	$t8, 0($t6)	# $t8 = sorted[i]
	sw	$t8, 0($t7)	# sorted[maxIndex] = sorted[i]
	sw	$t5, 0($t6)	# sorted[i] = temp;
	addi	$t2, $t2, 4	# i++
	j 	loop_in_3	
return_2:
	jr 	$ra
	
	
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	addi	$sp, $sp, -4	# Reserve space on stack
	sw	$a1, 0($sp)	# Store $a1
	addi	$sp, $sp, -4	# Reserve space on stack
	sw	$ra, 0($sp)	# Store $ra
	addi	$sp, $sp, -4	# Reserve space on stack
	sw	$s0, 0($sp)	# Store $s0
	
	mul	$t0, $a1, 4	# $t0 stores the total number of bytes in the array
	slt	$t1, $zero, $t0
	bne	$t1, $zero, return_3	# if(len > 0)
	li	$v0, 0
	j	end
return_3:
	addi	$a1, $a1, -1	# $a0 = len - 1
	addi	$t0, $t0, -4	# $t0 = len - 1 (in bytes)
	add	$s0, $a0, $t0	# $s0 = *arr[len - 1]
	lw	$s0, 0($s0)	# $s0 = arr[len - 1]
	jal	calcSum		# calcSum(arr, len - 1)
	add	$v0, $v0, $s0	# return(calcSum(arr, len - 1) + arr[len - 1])
end:
	lw	$s0, 0($sp)	# Restore $s0
	addi	$sp, $sp, 4	# Release space on stack
	lw	$ra, 0($sp)	# Restore $ra
	addi	$sp, $sp, 4	# Release space on stack
	lw	$a1, 0($sp)	# Restore $a1
	addi	$sp, $sp, 4	# Release space on stack
	jr 	$ra