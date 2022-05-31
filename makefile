hoc1.out:	hoc.o # the file hoc1 is dependant on hoc.o
	gcc hoc.o -o hoc1.out -lm
# when hoc.o has changed, run the above command when make is run

clean:
	rm *.c *.o

# note that make has default settings for YACC
# hence the lack of explicit YACC instructions 