.text
	###################################
	#	INPUT: a0 - string address, a1 - number address
	# OUTPUT: nothing
	# DESC: translate int number to string
	fill_number_string:
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)
		addi fp, sp, STACK_CHUNK

		li s10, 10 # always 10
		li s1, 18 # char iterator
		li s2, 12 # number iterator

		# during one iteration 4 numbers are changed
		# it is started from the end of the string
		fill_string_loop:
			add a3, a1, s2
			lw a4, (a3)

			# translate number to char
			rem t4, a4, s10
			div a4, a4, s10
			addi t4, t4, ZERO_CHAR
			# write char
			add a2, a0, s1
			sb t4, (a2)
			addi s1, s1, -1

			# translate number to char
			rem t3, a4, s10
			div a4, a4, s10
			addi t3, t3, ZERO_CHAR
			# write char
			add a2, a0, s1
			sb t3, (a2)
			# move char iterator
			addi s1, s1, -1

			# translate number to char
			rem t2, a4, s10
			div a4, a4, s10
			addi t2, t2, ZERO_CHAR
			# write char
			add a2, a0, s1
			sb t2, (a2)
			# move char iterator
			addi s1, s1, -1

			# translate number to char
			rem t1, a4, s10
			div a4, a4, s10
			addi t1, t1, ZERO_CHAR
			# write char
			add a2, a0, s1
			sb t1, (a2)
			# move char iterator
			addi s1, s1, -1

			# avoid space char in the string
			addi s1, s1, -1
			# move number iterator
			addi s2, s2, -4
		bgez s2, fill_string_loop

		li a0, 0

		# epilogue
		lw fp, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, STACK_CHUNK
		ret
