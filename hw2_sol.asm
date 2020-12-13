.section .data
open_paren: .ascii "("
close_paren: .ascii ")"
plus: .ascii "+"
minus: .acsii "-"
multi: .ascii "*"
divid: .ascii "/"
msg: .fill 10, 1, 0
msg_len: quad msg_len - msg

.section .bss
.lcomm temp_res, 8
.lcomm diff, 4

.section .text

.global	calc_expr
calc_expr:
	#calc_expr callee epilogue{
	pushq %rbp #save old rbp
	movq %rsp, %rbp # move rbp to top 
	# Save callee-save registers
	pushq %rbx 	#-64(%rsp) not 24
	pushq %rsi 	#-56(%rsp) not 16
	pushq %rdi 	#-48(%rsp) not 8
	pushq %rcx	#-40(%rsp)
	pushq %r8	#-32(%rsp)
	pushq %r9	#-24(%rsp)
	pushq %r10 	#-16(%rsp)
	pushq %r11 	#-8(%rsp)
#}

	xor %rbx, %rbx #long long res;
	
#syscall (read) caller epilogue{
	movq $0, %rax #read
	movq $0, %rdi #stdin
	movq $msg, %rsi
	movq $??, %rdx #TBD: what is the expr max_size? maybe should read expr in a loop... 
#}
	syscall

#syscall caller prologue {}

#calc_rec caller epilogue{
	movq $msg, %rdi
	movq %rax, %rsi
	movq -8(%rsp), %rdx 
#}
	call calc_rec

#calc_rec caller prologue {}

	
#result_as_string caller epilogue{
	movq %rax, %rdi
#}
	call* -16(%rsp) #call result_as_string
#result_as_string caller prologue{}

#syscall (write) caller epilogue{
	movq $1, %rax #write
	movq $1, %rdi #stdout
	movq $??, %rsi #TBD: change adress to be what_to_print. should we add "what_to_print" in the bss section?
	movq ???, %rdx #TBD: change this adress to be len(what_to_print)
#}
	syscall

#calc_expr callee prologue{
	pushq %r11 	
	pushq %r10 	
	pushq %r9	
	pushq %r8	
	pushq %rcx		
	popq %rdi
	popq %rsi
	popq %rbx
	popq %rbp
#}
	ret


calc_rec: #rdi = *str, rsi = len
	#prologue
	pushq %rbp
	movq %rsp, %rbp
	
	mov $0, (diff) #diff =0
	mov $-1, %rcx #rcx = i =-1
	main_loop:
		inc %rcx
		movb (%rdi, %rcx, 1), %al #curr = str[i]
		cmp %al, (open_paren) #if curr == '(' diff ++
		je diff++
		cmp %al, (close_paren) #if curr == ')' diff --
		je diff--
		
		check_char:
			cmp (diff), $1 #if diff == 1)
			jne main_loop
			
			cmp %al, (plus)
			je add_op

			cmp %al, (minus)
			je minus_op

			cmp %al, (multi)
			je mult_op

			cmp %al, (divid)
			je div_op

			cmp %rcx, %rsi
			jle main_loop

		after_loop:
			cmp %al, (open_paren)
			je remove_parenthesis

			#pre call
			pushq %rax
			pushq %rdi
			pushq %rsi
			pushq %rcx
			pushq %r8
			pushq %r9
			pushq %r10
			pushq %r11

			call string_convert

			mov %rax, (temp_res)

			#post call
			popq %r11
			popq %r10
			popq %r9
			popq %r8
			popq %rcx
			popq %rsi
			popq %rdi
			popq %rax

			mov (temp_res), %rax

			#epilogue
			leave
			ret


diff++: 
	inc (diff)
	jmp check_char


diff--:
	dec (diff)
	jmp check_char

add_op:
	mov %rdi, %r8   #str = temp_str = r8
	inc %rdi	#str +1
	mov %rcx, %r9	#i = temp_i = r9
	sub $2, %rcx    #i= i-2
	mov %rsi, %r10  #len = temp_len = r10
	mov %rcx, %rsi  #len = i-2
	
	#pre call
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	call calc_rec

	mov %rax, (temp_res) #temp_res = left

	#post call
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rsi
	popq %rdi
	popq %rax

	mov (temp_res), %r11 #temp_left = temp_res = left
	add %r9, %rdi  #str = str+1 +i
	mov %r10, %rsi #len = len
	sub %r9, %rsi  #len = len-i
	add $2, %rsi   #len = len-1+2
	
	#precall
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	call calc_rec
	
	mov %rax, (temp_res) #temp_res = right

	#post call
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rsi
	popq %rdi
	popq %rax

	add %r11, (temp_res) #temp_res =temp_left+right
	mov %r8, %rdi  #str = str
	mov %r9, %rcx  #i=i
	mov %r10, %rsi #len = len
	mov (temp_res), %rax #rax = left+right

	#epilogue
	leave
	ret

minus_op:
	movb -1(%rdi, %rcx, 1), %al #curr = str[i-1]
	cmp %al, (open_paren)
	je main_loop

	mov %rdi, %r8   #str = temp_str = r8
	inc %rdi	#str +1
	mov %rcx, %r9	#i = temp_i = r9
	sub $2, %rcx    #i= i-2
	mov %rsi, %r10  #len = temp_len = r10
	mov %rcx, %rsi  #len = i-2
	
	#pre call
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	call calc_rec

	mov %rax, (temp_res) #temp_res = left

	#post call
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rsi
	popq %rdi
	popq %rax

	mov (temp_res), %r11 #temp_left = temp_res = left
	add %r9, %rdi  #str = str+1 +i
	mov %r10, %rsi #len = len
	sub %r9, %rsi  #len = len-i
	add $2, %rsi   #len = len-1+2
	
	#precall
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	call calc_rec
	
	mov %rax, (temp_res) #temp_res = right

	#post call
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rsi
	popq %rdi
	popq %rax

	sub (temp_res), %r11 #temp_res =temp_left-right
	mov %r8, %rdi  #str = str
	mov %r9, %rcx  #i=i
	mov %r10, %rsi #len = len
	mov (temp_res), %rax #rax = left+right

	#epilogue
	leave
	ret
	
	

mult_op:
	mov %rdi, %r8   #str = temp_str = r8
	inc %rdi	#str +1
	mov %rcx, %r9	#i = temp_i = r9
	sub $2, %rcx    #i= i-2
	mov %rsi, %r10  #len = temp_len = r10
	mov %rcx, %rsi  #len = i-2
	
	#pre call
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	call calc_rec

	mov %rax, (temp_res) #temp_res = left

	#post call
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rsi
	popq %rdi
	popq %rax

	mov (temp_res), %r11 #temp_left = temp_res = left
	add %r9, %rdi  #str = str+1 +i
	mov %r10, %rsi #len = len
	sub %r9, %rsi  #len = len-i
	add $2, %rsi   #len = len-1+2
	
	#precall
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	call calc_rec
	
	mov %rax, (temp_res) #temp_res = right

	#post call
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rsi
	popq %rdi
	popq %rax

	mov %r8, %rdi  #str = str
	mov %r9, %rcx  #i=i
	mov %r10, %rsi #len = len
	mov (temp_res), %rax #rax = right

	mul %r11 #rax = right*left

	#prologue
	leave
	ret

div_op:
	mov %rdi, %r8   #str = temp_str = r8
	inc %rdi	#str +1
	mov %rcx, %r9	#i = temp_i = r9
	sub $2, %rcx    #i= i-2
	mov %rsi, %r10  #len = temp_len = r10
	mov %rcx, %rsi  #len = i-2
	
	#pre call
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	call calc_rec

	mov %rax, (temp_res) #temp_res = left

	#post call
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rsi
	popq %rdi
	popq %rax

	mov (temp_res), %r11 #temp_left = temp_res = left
	add %r9, %rdi  #str = str+1 +i
	mov %r10, %rsi #len = len
	sub %r9, %rsi  #len = len-i
	add $2, %rsi   #len = len-1+2
	
	#precall
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	call calc_rec
	
	mov %rax, (temp_res) #temp_res = right

	#post call
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rsi
	popq %rdi
	popq %rax

	mov %r8, %rdi  #str = str
	mov %r9, %rcx  #i=i
	mov %r10, %rsi #len = len
	mov %r11, %rax #rax = left
	div %rax, (temp_res) #rax = left\right

	#epilogue
	leave
	ret

remove_parenthesis:
	inc %rdi
	dec %rsi

