/*
	Dainternetdude
	2022
*/

// register macros
define(fp, x29)						// x29 is the frame pointer register
define(lr, x30)						// x30 is the link register

// constant macros
define(EOF, -1)
define(NUMBER, 0)
define(TOOBIG, 9)
define(MAXOP, 20)

// array declarations
		.bss					// store some stuff in bss section (initialized to zero)
array_m:	.skip	MAXOP				// declare array as a variable char array of length 20

		.text					// store next stuff in the text section of memory

// memory allocation settings for main
alloc = -(16 + 0) & -16
dealloc = -alloc

enterx:		.string	"Enter X co-ordinate: "
entery:		.string "Enter Y co-ordinate: "
output:		.string "Region is: %i, %i\n"
test:		.string "test: %i\n"

		.balign 4				// align instructions to the quadword "grid" in rom
		.global main				// make main function globally accessible
main:		stp	fp, lr, [sp, alloc]!		// store frame pointer & link register
		mov	fp, sp				// advance frame pointer to stack pointer

		adr	x0, enterx			// load string into first argument
		bl	printf				// branch & link to printf
		bl	getcoord			// branch & link to getcoord
		//result is in w0
		mov	w1, w0
		//adr	x0, test
		//bl	printf

		bl	cleararray
		mov	x0, xzr

		adr	x0, entery			// load string into first arg
		bl	printf				// branch & link to printf
		bl	getcoord			// branch & link to getcoord
		// result is in w0
		mov	w1, w0
		//adr	x0, test
		//bl	printf

mainout:

		mov	x0, 0				// move function call success code (0) into first argument
		ldp	fp, lr, [sp], dealloc		// reload frame pointer & link register from stack
		ret					// return to calling code

// memory allocation stuff for cleararray
alloc = -(16 + 0) & -16
dealloc = -alloc

cleararray:
		stp	fp, lr, [sp, alloc]!
		mov	fp, sp

		mov	w0, 0				// i = 0
		adr	x1, array_m			// get address of array
while:
		str	xzr, [x1, w0, SXTW]		// store zero into array[i]
		add	w0, w0, 1			// i++
		cmp	w0, MAXOP			// compare i to array size
		b.ge	cleararrayout			// break out if i >= array size
		b	while

cleararrayout:
		ldp	fp, lr, [sp], dealloc
		ret

// memory allocation deets for getcoord
alloc = -(16 + 0) & -16
dealloc = -alloc

getcoord:
		stp	fp, lr, [sp, alloc]!
		mov	fp, sp

		adr	x0, array_m			// move address of array into first arg
		mov	x1, MAXOP			// move MAXOP into second arg (max array length)
		bl	getop				// branch & link to getop

		mov	w0, 0				// init result to 0
		mov	w1, 0				// i = 0
		adr	x3, array_m			// load address of array
		mov	w4, 10				// just gonna hold 10 in register w4 to speed up loop

getcoordfor:
		ldr	w2, [x3, w1, SXTW]		// load array[i] into register
		cmp	w2, 0x00			// see if array[i] is null
		b.eq	getcoordout			// break if so

		//todo compare to decimal point to handle decimals

		mul	w0, w0, w4			// shift decimal place one to the right
		sub	w2, w2, 0x30			// change value of number characters to their value as an int
		add	w0, w0, w2			// add to running total
		add	w1, w1, 1			// i++

		b	getcoordfor			// to top of loop

getcoordout:
		ldp	fp, lr, [sp], dealloc
		ret

define(BUFSIZE, 100)

		.bss				// store next variables in the zero-initialized section (bss)
buf_m:		.skip	BUFSIZE * 1		// declare buf as a variable char array
		.global	buf_m			// make buf globally accessable

		.data
bufp_m:		.word	0			// declare bufp as an int variable
		.global	bufp_m			// make bufp globally accessable

		.text				// store code in text section
		.balign	4			// guarantee quadword-alignment

// some memory allocation for getop()

// sizes of registers
x19_size = 8
x20_size = 8
x21_size = 8
x22_size = 8
x23_size = 8
x24_size = 8

// sizes of local (stack) variables for getop()
i_size = 4
c_size = 4

// size of memory to allocate (& deallocate) on the stack
alloc = -(16 + i_size + c_size + x19_size + x20_size + x21_size + x22_size + x23_size + x24_size) & -16
dealloc = -alloc

// locations of variables & registers
i_s = 16
c_s = 16 + i_size
x19_s = 24
x20_s = 32
x21_s = 40
x22_s = 48
x23_s = 56
x24_s = 64

getop:
		stp	x29, x30, [sp, alloc]!	// store stack frame and make room for local variables
		mov	x29, sp			// advance sp

		str	x19, [sp, x19_s]	// store x19
		str	x20, [sp, x20_s]	// store x20
		str	x21, [sp, x21_s]	// store x21
		str	x22, [sp, x22_s]	// store x22
		str	x23, [sp, x23_s]	// store x23
		str	x24, [sp, x24_s]	// store x24

		mov	x21, x0			// store address of s into x21
		mov	w22, w1			// store lim into w22

getoptop:
		bl	getch			// branch & link to getch
		str	w0, [sp, c_s]		// store result of getch into c
		mov	w19, w0			// move c into w19
		mov	w20, ' '		// move ' ' into w20
		cmp	w19, w20		// compare c with ' '
		b.eq	getoptop		// branch to top of while loop if they're equal
		mov	w20, '\t'		// move '\t' into w20
		cmp	w19, w20		// compare c with '\t'
		b.eq	getoptop		// branch to top of while loop if they're equal
		mov	w20, '\n'		// move '\n' into w20
		cmp	w19, w20		// compare c with '\n'
		b.eq	getoptop		// branch to top of while loop if they're equal

		mov	w20, '0'		// move '0' to w20
		cmp	w19, w20		// compare c to '0'
		b.lt	getopdown		// branch to body of if statement if c < '0'
		mov	w20, '9'		// move '9' to w20
		cmp	w19, w20		// compare c to '9'
		b.gt	getopdown		// branch to body of if statement if c < '0'
		b	getopdownn		// if none of the above are true branch out of the if statement
getopdown:
		mov	w0, w19			// move c into first param register
		b	getopout		// branch to end of function

getopdownn:
		str	w19, [x21]		// store c in the first element of s (the address of which is stored in x21)

		mov	w20, 1			// move 1 into w20
		str	w20, [sp, i_s]		// store 1 to i

getopforloop:
		bl	getchar			// branch & link to getchar
		str	w0, [sp, c_s]		// store c to stack
		mov	w19, w0			// move value of c into w19 for easy handling
		mov	w23, '0'		// move '0' into w23
		cmp	w19, w23		// compare c to '0'
		b.lt	getopforloopout		// if c < '0' exit for loop
		mov	w23, '9'		// move '9' into w23
		cmp	w19, w23		// compare c to '9'
		b.gt	getopforloopout		// if c > '9' exit for loop

		ldr	w24, [sp, i_s]		// load i from stack
		cmp	w24, w22		// compare i to lim
		b.ge	getopifout		// if i >= lim exit if statement

		str	w19, [x21, w24, SXTW]	// store c in s[i]

getopifout:					// end of if statement
		ldr	w20, [sp, i_s]		// load i into register w20
		add 	w20, w20, 1		// increment i by one
		str	w20, [sp, i_s]		// store i into the stack
		b	getopforloop		// branch to top of for loop
getopforloopout:

		ldr	w20, [sp, i_s]		// load i into register w20
		cmp	w20, w22		// compare i to lim
		b.ge	ifend			// branch to else statement if i >= lim

		ldr	w0, [sp, c_s]		// load c into register w0 (first parameter)
		bl	ungetch			// branch & link to ungetch

		mov	w19, 0			// move '\0' into register w19
		ldr	w20, [sp, i_s]		// load i into w20
		str	w19, [x21, w20, SXTW]	// store '\0' into s[i]

		mov	w0, NUMBER		// move NUMBER into w0
		b	getopout		// branch to end of function

ifend:

getopwhile2:
		ldr	w19, [sp, c_s]		// load c into register w19
		mov	w20, '\n'		// move '\n' into register w20
		cmp	w19, w20		// compare c to '\n'
		b.eq	getopwhile2out		// if c == '\n' branch to outside of while loop
		mov	w20, EOF		// move EOF into register w20
		cmp	w19, w20		// compare c to EOF
		b.eq	getopwhile2out		// it c == EOF branch to outside of while loop

		bl	getchar			// branch & link to getchar
		str	w0, [sp, c_s]		// store result of getchar into c
		b	getopwhile2		// branch to beginning of while loop

getopwhile2out:
		mov	w19, 0			// move '\0' into register w19
		sub	w20, w22, 1		// subtract 1 from lim & store it in w20
		str	w19, [x21, w22, SXTW]	// store '\0' in s[lim-1]

		mov	w0, TOOBIG		// move TOOBIG into w0 (first parameter)
		// return will happen soon

		ldr	x19, [sp, x19_s]	// load x19
		ldr	x20, [sp, x20_s]	// load x20
		ldr	x21, [sp, x21_s]	// load x21
		ldr	x22, [sp, x22_s]	// load x22
		ldr	x23, [sp, x23_s]	// load x23
		ldr	x24, [sp, x24_s]	// load x24

getopout:	ldp	x29, x30, [sp], dealloc	// restore saved stack frame
		ret				// return to calling code

// some memory allocation for getch()
x19_size = 8
x20_size = 8
x21_size = 8
alloc = -(16 + x19_size + x20_size + x21_size) & -16
dealloc = -alloc
x19_s = 16
x20_s = 24
x21_s = 32

getch:
		stp	x29, x30, [sp, alloc]!	// store stack frame & make room for a new one
		mov	x29, sp			// advance sp

		str	x19, [sp, x19_s]	// store x19
		str	x20, [sp, x20_s]	// store x20
		str	x21, [sp, x21_s]	// store x21

		adr	x19, bufp_m		// load address of bufp into x19
		ldr	w20, [x19]		// load bufp into w20
		cmp	w20, 0			// compare bufp with 0
		b.le	downn			// if bufp > 0 continue

		sub	w20, w20, 1		// decrement bufp by one
		adrp	x21, bufp_m		// load address of bufp into x21
		add	x21, x21, :lo12:bufp_m
		str	w20, [x21]		// store bufp
		sxtw	x20, w20		// sign extend register holding bufp to 64 bits wide
		adr	x19, buf_m		// load base address of buf
		add	x19, x19, x20		// add bufp to address of buf
		ldr	w0, [x19]		// load buf[bufp] into w0
		b	out			// branch to end of function

downn:
		bl	getchar			// branch & link to getchar

out:						// end of function
		ldr	x19, [sp, x19_s]	// load x19
		ldr	x20, [sp, x20_s]	// load x20
		ldr	x21, [sp, x21_s]	// load x21

		ldp	x29, x30, [sp], dealloc	// reload stack frame that we saved
		ret				// return to calling code

// some memory allocation for ungetch
x19_size = 8
x20_size = 8
x27_size = 8
x28_size = 8
alloc = -(16 + x19_size + x20_size + x27_size + x28_size) & -16
dealloc = -alloc
x19_s = 16
x20_s = 24
x27_s = 32
x28_s = 40

fmt:		.string "ungetch: too many characters\n"
		.balign 4

ungetch:
		stp	x29, x30, [sp, alloc]!	// store make space in the stack frame
		mov	x29, sp			// advance sp

		str	x19, [sp, x19_s]	// store x19
		str	x20, [sp, x20_s]	// store x20
		str	x27, [sp, x27_s]	// store x27
		str	x28, [sp, x28_s]	// store x28

		mov	w0, w20			// store parameter 1 (int c) in w20

		adr	x19, bufp_m		// load address of bufp into x19
		ldr	w20, [x19]		// load bufp into w20
		cmp	w20, BUFSIZE		// compare bufp to BUFSIZE
		b.le	elsee			// if bufp > BUFSIZE continue, else go to else statement

		adr	x0, fmt			// load address of fmt into first argument
		bl	printf			// branch & link to printf
		b	outt			// branch to outside of if statement

elsee:
		adr	x19, bufp_m		// load address of bufp into x19
		ldr	w27, [x19]		// load bufp into w21
		sxtw	x27, w27		// sign extend bufp to 64-bits wide
		adr	x19, buf_m		// load address of buf into x19
		add	x28, x19, x27		// add bufp to the address of buf & store result in x22
		ldr	w20, [sp, c_s]		// load c into register w20
		str	w20, [x28]		// store c to the address in x22 (buf base + offset = address of array element)
		add	w27, w27, 1		// increment bufp by one
		adrp	x28, bufp_m		// load address of bufp into x22
		add	x28, x28, :lo12:bufp_m
		str	w27, [x28]		// store bufp

outt:						// outside of if statement

		ldr	x19, [sp, x19_s]	// load x19
		ldr	x20, [sp, x20_s]	// load x20
		ldr	x27, [sp, x27_s]	// load x27
		ldr	x28, [sp, x28_s]	// load x28

		ldp	x29, x30, [sp], dealloc	// reload saved stack frame state
		ret				// return to calling code
