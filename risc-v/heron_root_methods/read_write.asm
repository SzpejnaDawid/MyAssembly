.global read_fun
.global write_fun
.eqv READ_SYSCALL, 63
.eqv WRITE_SYSCALL, 64

.text
	###################################
	#	INPUT: a0 - file descriptor, a1 - address of buffer for data, a2 - size of buffer 
	# OUTPUT: nothing
	# DESC: read data from file descriptor to buffer
	read_fun:
		li a7, READ_SYSCALL
		ecall
		ret

	###################################
	#	INPUT: a0 -file descriptor, a1 - address of buffer with data, a2 - size of buffer
	# OUTPUT: nothing
	# DESC: write data from buffer to file descriptor
	write_fun:
		li a7, WRITE_SYSCALL
		ecall
		ret