#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
//# <STUDENT FILL>
	asm volatile("sidt (%0);"
	:
	:"g" (idtr)
	:
	);
	// TODO: if we omit inline assembly:  store_idt(&tmpidtr);
// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL>
	asm volatile("lidt (%0);"
	:
	:"g" (idtr)
	:
	);
	// if we omit inline assembly: load_idt(addr);
// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL>

	asm volatile(
	"movq %0, %%rax;"
	"movq %1, %%rbx;"
	"movw %%bx, (%%rax);"
	"shrq $16, %%rbx;"
	"movw %%bx, 6(%%rax);"
	"shrq $16, %%rbx;"
	"movl %%ebx, 8(%%rax);"
	:
	: "r" (gate), "r" (addr)
	:"%rax", "%rbx"
	);
	
	//pack_gate(gate, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL>

	unsigned long addr;
	asm volatile(
	"movq %1, %%rbx;"
	"movl 8(%%rbx), %%eax;"
	"salq $16, %%rax;"
	"movw 6(%%rbx), %%ax;"
	"salq $16, %%rax;"
	"movw (%%rbx), %%ax;"
	"movq %%rax, %0;"
	:"=r" (addr)
	:"r" (gate)
	:"%rax","%rbx"
	);
	return addr;
	
	//return gate_offset(gate);
// </STUDENT FILL>
}
