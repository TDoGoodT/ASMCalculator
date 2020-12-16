#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
//# <STUDENT FILL>
	asm volatile("movq %%idtr, %%rdi;"
	"leave;"
	"ret;"
	:
	:
	:
	);
	// TODO: if we omit inline assembly:  store_idt(&tmpidtr);
// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL>
	asm volatile("movq %%rdi, %%idtr;"
	"leave;"
	"ret;"
	:
	:
	:
	);
	// if we omit inline assembly: load_idt(addr);
// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL>
//*gate = rdi addr =rsi
	asm volatile("pushq %%rax;"
	"movq %%rsi, %%rax;"
	"movw %%ax, (%%rdi);"
	"shrq %16, %%rax;"
	"movw %%ax, 6(%%rdi);"
	"shrq %15, %%rax;"
	"movl %%eax, 8(%%rdi);"
	"popq %%rax;"
	
	"leave;"
	"ret;"
	:
	:
	:
	);
	
	// TODO: pack_gate(gate, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL>
	asm volatile("movq %%rdi, %%rax;"
	"sub %%idtr, %%rax;"
	"leave;"
	"ret;"
	:
	:
	:
	);
	// TODO: return gate_offset(gate);
// </STUDENT FILL>
}
