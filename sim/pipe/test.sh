#!/bin/sh
./correctness.pl | grep "pass correctness test"
./correctness.pl -p | grep "pass correctness test"
cd ../ptest && make SIM=../pipe/psim TFLAGS=-i | grep "failed"
cd ../y86-code make testpsim | grep "Fails"
cd ../pipe
./benchmark.pl | grep "Average CPE"