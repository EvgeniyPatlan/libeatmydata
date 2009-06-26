all: libs fsynctest

clean:
	rm -f libeatmydata.so* fsynctest

libs: eatmydata.c
	gcc -shared -Wl,-soname,libeatmydata.so.1  -ldl -o libeatmydata.so.1.0  eatmydata.c -fPIC
	@rm -f libeatmydata.so.1 libeatmydata.so
	ln -s libeatmydata.so.1.0 libeatmydata.so.1
	ln -s libeatmydata.so.1 libeatmydata.so

fsynctest: fsynctest.c
	gcc -o fsynctest fsynctest.c

test: runfsynctest

testpat := '^[a-z]*sync\|O_SYNC'
runfsynctest:
	LD_PRELOAD=./libeatmydata.so strace -o fsynctest.result.run ./fsynctest
	! grep $(testpat) fsynctest.result.run
	rm fsynctest.result.run
	@echo
	@echo "Good: no *sync calls"
	@#grep $(testpat) fsynctest.result.run |sed -e 's%[0-9]* vars%%' > fsynctest.result.run.out
	@#mv fsynctest.result.run.out fsynctest.result.run
	@#diff fsynctest.result fsynctest.result.run
