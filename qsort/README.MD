# Requirements
nasm and probably a 64 bit linux machine 

# Usage
```
$ make && ./qsort [...numbers] 
```
With bash, the numbers can be passed as command line arguments quite easily from a file (both spaces and newlines are supported as delimiters)
```
$ ./qsort $(< filename.txt)
```

## Debug
```
$ make debug && (gdb or ddd) qsort
```
(if you already built it normally and didn't change anything, do a `$ make clean` before)

## Notes
Expects 32 bit signed integers

### Algorithm
[Sauce](https://en.wikipedia.org/wiki/Quicksort#Hoare_partition_scheme)
