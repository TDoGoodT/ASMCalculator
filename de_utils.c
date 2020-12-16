#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
//# <STUDENT FILL>
	asm volatile ("sidt (%0);"
	:
	:"g" (idtr)
	:
	);
	// TODO: if we omit inline assembly:  store_idt(&tmpidtr);
// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL>
	asm volatile ("lidt (%0);"
	:
	:"g" (idtr)
	:
	);
	// if we omit inline assembly: load_idt(addr);
// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL>
//*gate = rdi addr =rsi
	/*asm volatile (
	"movq %1, %%rax;"
	"movw %%ax, (%0);"
	"shrq $16, %%rax;"
	"movw %%ax, 6(%0);"
	"shrq $16, %%rax;"
	"movl %%eax, 8(%0);"
	:
	:"r" (gate), "r" (addr)
	:"%rax"
	);*/
	
	pack_gate(gate, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL>
	/*unsigned long res;
	asm volatile (
	"movq %%rdi, %%rax;"
	"lidt (%1);"
	"sub %1, %%rax;"
	"movq %%rax, %0;"
	:"=r" (res)
	:"r" (gate)
	:"%rax"
	);
	return res;*/
	return gate_offset(gate);
// </STUDENT FILL>
}
