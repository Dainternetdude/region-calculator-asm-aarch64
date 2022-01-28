/*
	Dainternetdude
	2021
*/

define(x29, fp)						// x29 is the frame pointer register
define(x30, lr)						// x30 is the link register
define(BUFSIZE, 100)

		.bss					// store some stuff in bss section (initialized to zero)
buf_m		.skip	BUFSIZE * 1			// declare buf (buffer) as a variable char array of length BUFSIZE
		.global buf_m

		.data					// store next stuff in the data section
bufp_m:		.word	0				// declare bufp (buffer pointer) as an int variable
		.global	bufp_m				// make buf globally accessible

		.text					// store next stuff in the text section of memory

alloc = -(16 + 0) & -16
dealloc = -alloc

enterx:		.string	"Enter X co-ordinate: "
entery:		.string "Enter Y co-ordinate: "
output:		.string "Region is: %d, %d\n"

		.balign 4				// align instructions to the quadword "grid" in rom
		.global main				// make main function globally accessible
main:		stp	fp, lr, [sp, alloc]!		// store frame pointer & link register
		mov	fp, sp				// advance frame pointer to stack pointer

		adr	x0, enterx			// load string into first argument
		bl	printf				// branch & link to printf

// main while loop
mainwhile:	bl	get
		cmp	w0, -1				// compare type to End Of Field character
		b.eq 	mainwhileout			// break when you receive EOF

// compare chars to see what the new char is
// and do necessary operations to get an integer

mainwhileout:

		mov	x0, 0				// move function call success code (0) into first argument
		ldp	fp, lr, [sp], dealloc		// reload frame pointer & link register from stack
		ret					// return to calling code

getch:		// maybe will use this function
		adr	x0, bufp_m			// load address of bufp into x0
		ldr	w20, [x0]			// load value of bufp into w20
		cmp	w20, 0				// compare bufp with 0
		b.le	down				// if bufp > 0 continue

		sub	w20, w20, 1			// decrement bufp by one
		adr	x0, bufp_m			// load address of bufp into x0
		str	w20, [x0]			// store bufp to memory

		sxtw	x20, w20			// sign extend register holding bufp to 64 bits wide
		adr	x0, buf_m			// load base address of buf
		add	x0, x0, x20			// add bufp offset to buf base address
		ldr	w1, x0				// load buf[bufp] into w1
		b	out				// branch out

down:		bl	getchar				// branch & link to getchar

out:
