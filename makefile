region-calculator.o: region-calculator.s
	gcc -g region-calculator.s -o region-calculator.o

region-calculator.s: region-calculator.asm
	m4 region-calculator.asm > region-calculator.s
