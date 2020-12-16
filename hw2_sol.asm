.section .data
open_paren: .ascii "("
close_paren: .ascii ")"
plus: .ascii "+"
minus: .ascii "-"
multi: .ascii "*"
divid: .ascii "/"
EON: .ascii "\n"
string_to_convert: .zero 30

.section .bss
.lcomm temp_res, 8
.lcomm diff, 4
.lcomm string_convert, 8
.lcomm result_as_string, 8

.section .text

.global	calc_expr
calc_expr:
#calc_expr callee epilogue{
	pushq %rbp #save old rbp
	movq %rsp, %rbp # move rbp to top 
	# Save callee-save registers
	pushq %rbx 	#-64(%rsp) 
	pushq %rsi 	#-56(%rsp) 
	pushq %rdi 	#-48(%rsp) 
	pushq %rcx	#-40(%rsp)
	pushq %r8	#-32(%rsp)
	pushq %r9	#-24(%rsp)
	pushq %r10 	#-16(%rsp)
	pushq %r11 	#-8(%rsp)
	movq %rdi, string_convert
	movq %rsi, result_as_string
	movq %rsp, %r10
#}

	xor %rbx, %rbx #long long res;
		
	movq %rsp, %r11 #char* tmp = current_stack_pointer
read_char:
#syscall (read) caller epilogue{
	movq $0, %rax #read
	movq $0, %rdi #stdin
	movq $1, %rdx #read char by char
#}
	movq %rsp, %rsi 
	dec %rsp 
	syscall	
	
	movb (%rsi), %r11b
	cmpb (EON), %r11b
	jne read_char
	inc %rsp

#calc_rec caller epilogue{
	movq %r10, %rdi
	subq %rsp, %r10 #len(str) -> %r10
	movq %r10, %rsi # %rsi = len(str)
	movq $string_convert, %rdx 
#}

	call calc_rec

#calc_rec caller prologue {}

	
#result_as_string caller epilogue{
	movq %rax, %rdi
#}
	call *result_as_string
#result_as_string caller prologue{}

#syscall (write) caller epilogue{
	movq %rax, %rdx # %rax <- len(what_to_print)
	movq $1, %rax #write
	movq $1, %rdi #stdout
	movq $what_to_print, %rsi 
	
#}
	syscall

#calc_expr callee prologue{
	popq %r11 	
	popq %r10 	
	popq %r9	
	popq %r8	
	popq %rcx		
	popq %rdi
	popq %rsi
	popq %rbx
#}
	leave
	ret

calc_rec: #rdi = *str, rsi = len
	#prologue

	pushq %rbp
	movq %rsp, %rbp
	
	movl $0, (diff) #diff =0
	mov $-1, %rcx #rcx = i =-1
	main_loop:
		inc %rcx

		imul $-1, %rcx, %rcx

		movb (%rdi, %rcx, 1), %al #curr = str[i]

		imul $-1, %rcx, %rcx

		cmp %al, (open_paren) #if curr == '(' diff ++
		je diff_pp
		cmp %al, (close_paren) #if curr == ')' diff --
		je diff_mm
		
		check_char:
			movl $1, %r8d
			cmpl %r8d,(diff)  #if diff == 1)
			jne main_loop_end
			
			cmp %al, (plus)
			je add_op

			cmp %al, (minus)
			je minus_op

			cmp %al, (multi)
			je mult_op

			cmp %al, (divid)
			je div_op
		main_loop_end:
			cmp %rsi, %rcx
			jle main_loop

		after_loop:
			xor %rcx, %rcx
			movb (%rdi, %rcx, 1), %al
			cmpb %al, (open_paren)
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

			#movq $1, %rax
			#movq %rsi, %rdx
			#movq %rdi, %r8
			#sub  %rsi, %r8
			#movq %r8, %rsi
			#inc %rsi
			#movq $1, %rdi

			#syscall





			jmp create_string
			
		use_string_convert:	

			#movq $1, %rax
			#movq %rsi, %rdx
			#movq $1, %rdi
			#movq $string_to_convert, %rsi

			#syscall
			
			

			movq $string_to_convert, %rdi	

			call *string_convert

			mov %rax, (temp_res)

			jmp delete_string

		after_string_convert:

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


diff_pp: 
	incl (diff)
	jmp main_loop


diff_mm:
	decl (diff)
	jmp main_loop

add_op:
	mov %rdi, %r8   #str = temp_str = r8
	dec %rdi	#str +1
	mov %rcx, %r9	#i = temp_i = r9
	dec %rcx    #i= i--
	mov %rsi, %r10  #len = temp_len = r10
	mov %rcx, %rsi  #len = i--
	
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
	sub %r9, %rdi  #str = str+1 +i
	mov %r10, %rsi #len = len
	sub %r9, %rsi  #len = len-i
	sub $2, %rsi   #len = len-(i+2)
	
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
	movq $0, %r8
	cmp %rcx, %r8
	je main_loop
	
	imul $-1, %rcx, %rcx
	movb 1(%rdi, %rcx, 1), %al #curr = str[i-1]
	imul $-1, %rcx, %rcx

	cmp %al, (open_paren)
	je main_loop

	mov %rdi, %r8   #str = temp_str = r8
	dec %rdi	#str +1
	mov %rcx, %r9	#i = temp_i = r9
	dec %rcx    #i= i--
	mov %rsi, %r10  #len = temp_len = r10
	mov %rcx, %rsi  #len = i--
	
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
	sub %r9, %rdi  #str = str+1 +i
	mov %r10, %rsi #len = len
	sub %r9, %rsi  #len = len-i
	sub $2, %rsi   #len = len-(i+2)
	
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
	mov %r11, %rax #rax = left-right

	#epilogue
	leave
	ret
	
	

mult_op:
	mov %rdi, %r8   #str = temp_str = r8
	dec %rdi	#str +1
	mov %rcx, %r9	#i = temp_i = r9
	dec %rcx    #i= i--
	mov %rsi, %r10  #len = temp_len = r10
	mov %rcx, %rsi  #len = i--
	
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
	sub %r9, %rdi  #str = str+1 +i
	mov %r10, %rsi #len = len
	sub %r9, %rsi  #len = len-i
	sub $2, %rsi   #len = len-(i+2)
	
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
	dec %rdi	#str +1
	mov %rcx, %r9	#i = temp_i = r9
	dec %rcx    #i= i--
	mov %rsi, %r10  #len = temp_len = r10
	mov %rcx, %rsi  #len = i--
	
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
	sub %r9, %rdi  #str = str+1 +i
	mov %r10, %rsi #len = len
	sub %r9, %rsi  #len = len-i
	sub $2, %rsi   #len = len-(i+2)
	
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

	mov %r8, %rdi  #str = str
	mov %r9, %rcx  #i=i
	mov %r10, %rsi #len = len
	mov %r11, %rax #rax = left

	pushq %rdx

	xor %rdx, %rdx
	divq (temp_res) #rax = left\right

	popq %rdx

	#epilogue
	leave
	ret

remove_parenthesis:
	dec %rdi
	dec %rsi
	dec %rsi
	mov $-1, %rcx
	jmp main_loop

create_string:
	xor %rcx, %rcx
	inner_loop:
		cmp %rsi, %rcx
		jge use_string_convert
		movq $string_to_convert, %r10
		leaq (%r10, %rcx, 1), %r9

		imul $-1, %rcx, %rcx

		movb (%rdi, %rcx, 1), %al #curr = str[i]
		
		movb %al, (%r9)

		imul $-1, %rcx, %rcx

		inc %rcx

		jmp inner_loop
		
delete_string:
	movq $30, %r8
	xor %rcx, %rcx
	
	del_inner_loop:
		movq $string_to_convert, %r10
		cmp %rcx, %r8
		jg after_string_convert
		movb $0, (%r10, %rcx, 1)
		inc %rcx
		jmp del_inner_loop

