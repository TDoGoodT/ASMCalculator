.globl my_de_handler
.extern what_to_do, old_de_handler

.data

.bss
.lcomm temp_res, 8


.text
.align 4, 0x90
my_de_handler:
  #STUDENT NEED TO FILL
  
	
	pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	pushfq
	
	xor %r8, %r8
	
	movq %rax, %rdi
		
	call what_to_do #get handler response
		
	cmp %rax, %r8  #cmp handler response to 0
	je old_handler
	
	movq %rax, (temp_res)
	
	popfq
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	popq %rax
	
	movq (temp_res), %rax
	
	movq $1, %rbx
	cqo
	
	iretq
	
	old_handler:

		popfq
		popq %r11
		popq %r10
		popq %r9
		popq %r8
		popq %rcx
		popq %rdx
		popq %rsi
		popq %rdi
		popq %rax
		
		#movq (old_de_handler), %rcx
	
		call (old_de_handler) #get old handler response
		
		movq $5, %rcx
		
		iretq
		


