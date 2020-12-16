.globl my_de_handler
.extern what_to_do, old_de_handler

.data

.text
.align 4, 0x90
my_de_handler:
  #STUDENT NEED TO FILL
	pushq %rbp #save old rbp
	movq %rsp, %rbp # move rbp to top
	
	pushq %rdi
	pushq %r8
	
	movq %rax, %rdi #sends the divisor to teh first argument
	
	call *what_to_do #get handler response
	
	xor %r8, %r8  
	cmp %rax, %r8  #cmp handler response to 0
	jne end
	
	call *old_de_handler #get old handler response
	
	end:
		popq %r8
		popq %rdi
	
		leave
		ret
	
	
