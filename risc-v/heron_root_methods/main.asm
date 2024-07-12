.include "_start.asm"
.include "read_write.asm"
.eqv STACK_CHUNK, 16
.eqv STACK_TWO_CHUNK, 32

.include "root_alg.asm"

.eqv ASK_FOR_NUMBER_STR_LEN, 74 # without \0 character
.eqv WRONG_INPUT_STR_LEN, 86 # without \0 character
.eqv WRONG_INPUT_FORMAT_STR_LEN, 30 # without \0 character
.eqv BUFFER_SIZE, 20
.eqv LAST_CHARACTER_IN_DATA_BUFFER, 18

.eqv START_STACK_INT_4_ARRAY, 24

.eqv STDIN, 0
.eqv STDOUT, 1

.eqv ZERO_CHAR, 48 				# '0'
.eqv NINE_CHAR, 57 				# '9'
.eqv ABOVE_NINE_CHAR, 58  # '/'
.eqv BELOVE_ZERO_CHAR, 47 # ':'
.eqv SPACE_CHAR,  32			# ' '
.eqv NEW_LINE_CHAR, 10		# '/n'

.eqv ZERO_RETURN, 0
.eqv ONE_RETURN, 1
.eqv BYTE, 1

.include "create_string.asm"

.data
	data_buffer: .space BUFFER_SIZE
	ask_for_numbers_str: .asciz "Enter four numbers:\nXXXX XXXX XXXX XXXX\nwhere X is number between 0 and 9\n"
	wrong_input_str: .asciz "\nYou type wrong input. It should be\nXXXX XXXX XXXX XXXX\nwhere X is number between 0 and 9\n\n"
	wrong_input_format_str: .asciz "\nWrong format. End of program\n"

.text
	main:
		# prologue
		addi sp, sp, -STACK_TWO_CHUNK
		sw ra, 28(sp)
		sw fp, 24(sp)
		addi fp, sp, STACK_TWO_CHUNK

		# print info on STDOUT
		jal print_usage

		# type numbers from STDIN
		jal type_numbers

		# check if input is correct
		beqz a0, _continue1
			# if input is incorrect print 
			# a message and exit
			jal wrong_input
			li a0, ZERO_RETURN
			j main_epilogue

		_continue1:
		addi a0, fp, -START_STACK_INT_4_ARRAY
		mv a1, a0
		jal parse_input

		beqz a0, _continue2
			jal wrong_input_format
			li a0, ZERO_RETURN
			j main_epilogue

		_continue2:
		# calculate roots for 4 numbers
		# 1. number
		lw a0, (a1)
		jal square_root
		sw a0, (a1) # save results

		# 2. number
		lw a0, 4(a1)
		jal square_root
		sw a0, 4(a1) # save results

		# 3. number
		lw a0, 8(a1)
		jal square_root
		sw a0, 8(a1) # save results

		# 4. number
		lw a0, 12(a1)
		jal square_root
		sw a0, 12(a1) # save results

		# translate ints into string
		la a0, data_buffer
		mv a1, a1
		jal fill_number_string

		li a0, STDOUT
		la a1, data_buffer
		li a2, BUFFER_SIZE
		jal write_fun

		# exit from main with 0
		li a0, ZERO_RETURN

		# epilogue
		main_epilogue:
		lw fp, 24(sp)
		lw ra, 28(sp)
		addi sp, sp, STACK_TWO_CHUNK
		ret

	###################################
	#	INPUT: nothing 
	# OUTPUT: nothing
	# DESC: print information what user should do
	print_usage:
		# prologue
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)
		addi fp, sp, STACK_CHUNK

		# print message on STDOUT
		li a0, STDOUT
		la a1, ask_for_numbers_str
		li a2, ASK_FOR_NUMBER_STR_LEN
		jal write_fun

		# epilogue
		lw fp, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, STACK_CHUNK
		ret

	###################################
	#	INPUT: nothing 
	# OUTPUT: a0 - if read less than BUFFER_SIZE return 1, otherwise 0.
	# DESC: take input from user
	type_numbers:
		# prologue
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)

		# take input from STDIN
		li a0, STDIN
		la a1, data_buffer
		li a2, BUFFER_SIZE
		jal read_fun

		slti a0, a0, BUFFER_SIZE

		# epilogue
		lw ra, 12(sp)
		lw fp, 8(sp)
		addi sp sp, STACK_CHUNK
		ret

	###################################
	#	INPUT: nothing 
	# OUTPUT: nothing
	# DESC: print info that input has wrong length
	wrong_input:
		# prologue
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)
		addi fp, sp, STACK_CHUNK

		# print message on STDOUT
		li a0, STDOUT
		la a1, wrong_input_str
		li a2, WRONG_INPUT_STR_LEN
		jal write_fun

		# epilogue
		lw fp, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, STACK_CHUNK
		ret

	###################################
	#	INPUT: nothing 
	# OUTPUT: nothing
	# DESC: print information if input has wrong input
	wrong_input_format:
		# prologue
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)
		addi fp, sp, STACK_CHUNK

		# print message on STDOUT
		li a0, STDOUT
		la a1, wrong_input_format_str
		li a2, WRONG_INPUT_FORMAT_STR_LEN
		jal write_fun

		# epilogue
		lw fp, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, STACK_CHUNK
		ret

	###################################
	#	INPUT: a0 - address of buffer for parsed values.
	# OUTPUT: a0 - 1 if input format is wrong, otherwise 0.
	# DESC: parse input to check if input is good i.e. "XXXX XXXX XXXX XXXX\n"
	#       where X - is number between 0 to 9.
	parse_input:
		# prologue
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)
		addi fp, sp, STACK_CHUNK

		la t0, data_buffer # iterrator
		addi t1, t0, BUFFER_SIZE # it is data_buffer + 20
		# addi t1, t0, LAST_CHARACTER_IN_DATA_BUFFER # iterrator
		mv t3, a0 # remember address of parsed value buffer
		#addi t3, t3, 12 # set to the last cell in array

		li t4, 10 # this reg is always 10. I use it to mul
		li t5, 0 # this reg is for parsed value

		# while loop through characters
		loop:
			lb a0, (t0)

			mv t2, a0
			jal is_number
			if:
			beqz a0, else_if
				# new_sum = old_sum * 10 + (symbol - '0')
				mul t5, t5, t4 # t5 = old_sum * 10

				addi a0, t2, -ZERO_CHAR # a0 = (symbol - '0')
				add t5, t5, a0  # new_sum = t5 + a0

				j if_end
			else_if:
				mv a0, t2
				jal is_space_or_new_line
				beqz a0, else

				# load parsed value to array
				sw t5, (t3)
				# move array pointer
				addi t3, t3, 4

				# reset sum variable
				li t5, 0

				j if_end
			else:
				li a0, ONE_RETURN
				j parse_input_epilogue

			if_end:
			addi t0, t0, BYTE
		blt t0, t1, loop

		li, a0, ZERO_RETURN

		# epilogue
		parse_input_epilogue:
		lw fp, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, STACK_CHUNK
		ret

	###################################
	#	INPUT: a0 - is validated value
	# OUTPUT: a0 - if input is a number then 1, otherwise 0.
	# DESC: check if input is a number
	is_number:
		# prologue
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)
		addi fp, sp, STACK_CHUNK

		slti s1, a0, ABOVE_NINE_CHAR # a0 < '9' + 1
		li s2, BELOVE_ZERO_CHAR
		slt s2, s2, a0               # '0' - 1 < a0
		and a0, s1, s2               # a0 = '0' - 1 < a0 and a0 < '9' + 1

		# epilogue
		lw fp, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, STACK_CHUNK
		ret

	###################################
	#	INPUT: a0 - is validated value
	# OUTPUT: a0 - if input is a space or a new line then 1, otherwise 0.
	# DESC: check if input is space or new line char
	is_space_or_new_line:
		# prologue
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)
		addi fp, sp, STACK_CHUNK

		addi s1, a0, -SPACE_CHAR
		seqz s1, s1

		addi s2, a0, -NEW_LINE_CHAR
		seqz s2, s2
		
		or a0, s1, s2

		# epilogue
		lw fp, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, STACK_CHUNK
		ret
