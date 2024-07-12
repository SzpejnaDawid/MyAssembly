.global _start
.global _exit
.eqv EXIT_SYSCALL, 93

.text

	###################################
	# INPUT: nothing
	# OUTPUT: nothing
	# DESC: starting point of the program
	_start:
		jal main
		jal _exit

	_exit:
		li a7, EXIT_SYSCALL
		ecall
