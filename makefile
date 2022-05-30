hoc1.out:	hoc.o # the file hoc1 is dependant on hoc.o
	gcc hoc.o -o hoc1 -lm
# when hoc.o has changed, run the above command when make is run