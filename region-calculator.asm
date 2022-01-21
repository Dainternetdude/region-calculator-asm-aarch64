alloc = -(16 + 0) & -16
dealloc = -alloc

		.balign 4
		.global main
main:		stp	x29, x30, [sp, alloc]!
		mov	x29, sp

		// le code

		mov	x0, 0
		ldp	x29, x30, [sp], dealloc
		ret
