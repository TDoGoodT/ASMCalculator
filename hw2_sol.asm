.section .data
open_paren: .ascii "("
close_paren: .ascii ")"
plus: .ascii "+"
minus: .acsii "-"
multi: .ascii "*"
divid: .ascii "/"

.section .bss
.lcomm temp_res, 8
.lcomm diff, 4

.section .text

.global	calc_expr
calc_expr:
	#YOU NEED TO FILL THIS
	ret


calc_rec: #rdi = *str, rsi = len
	#prologue
	pushq %rbp
	movq %rbp, %rsp
	
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

