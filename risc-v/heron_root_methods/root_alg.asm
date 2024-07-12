.text
	###################################
	#	INPUT: a0 - integer number 
	# OUTPUT: square root as int value
	# DESC: calculate root of int using Heron's method
	square_root:
		# prologue
		addi sp, sp, -STACK_CHUNK
		sw ra, 12(sp)
		sw fp, 8(sp)
		addi fp, sp, STACK_CHUNK

		mv t0, a0
		li t1, 2
		div t0, t0, t1 
		fcvt.s.w ft0, t0 # x
		fcvt.s.w fa0, a0 # S

		fcvt.s.w ft2, t1 # const 2
		li t1, 20 # const 20

		# iterrator
		li t0, 0 

		# 20 e.i t1 iterration we use
		# x_n = 1/2 * (x_n-1 + S/x_n-1)
		loop_root:
			fdiv.s ft1, fa0, ft0
			fadd.s ft1, ft0, ft1
			fdiv.s ft0, ft1, ft2

			addi t0, t0, 1
		blt t0, t1, loop_root
	
		# convert from float to int
		fcvt.w.s a0, ft0
	
		# epilogue
		lw fp, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, STACK_CHUNK
		ret
