# #!/bin/sh

javac UnsafeMemory.java

echo "n_threads = 1"
# n_threads = 1
echo "nVals = 32"
time java UnsafeMemory $1 1 100 32
time java UnsafeMemory $1 1 101 32
time java UnsafeMemory $1 1 102 32
time java UnsafeMemory $1 1 103 32
time java UnsafeMemory $1 1 104 32
time java UnsafeMemory $1 1 105 32
echo "nVals = 64"
time java UnsafeMemory $1 1 100 64
time java UnsafeMemory $1 1 101 64
time java UnsafeMemory $1 1 102 64
time java UnsafeMemory $1 1 103 64
time java UnsafeMemory $1 1 104 64
time java UnsafeMemory $1 1 105 64
echo "nVals = 128"
time java UnsafeMemory $1 1 100 128
time java UnsafeMemory $1 1 101 128
time java UnsafeMemory $1 1 102 128
time java UnsafeMemory $1 1 103 128
time java UnsafeMemory $1 1 104 128
time java UnsafeMemory $1 1 105 128
echo "---"
echo "n_threads = 8"
# n_threads = 8
echo "nVals = 32"
time java UnsafeMemory $1 8 100 32
time java UnsafeMemory $1 8 101 32
time java UnsafeMemory $1 8 102 32
time java UnsafeMemory $1 8 103 32
time java UnsafeMemory $1 8 104 32
time java UnsafeMemory $1 8 105 32
echo "nVals = 64"
time java UnsafeMemory $1 8 100 64
time java UnsafeMemory $1 8 101 64
time java UnsafeMemory $1 8 102 64
time java UnsafeMemory $1 8 103 64
time java UnsafeMemory $1 8 104 64
time java UnsafeMemory $1 8 105 64
echo "nVals = 128"
time java UnsafeMemory $1 8 100 128
time java UnsafeMemory $1 8 101 128
time java UnsafeMemory $1 8 102 128
time java UnsafeMemory $1 8 103 128
time java UnsafeMemory $1 8 104 128
time java UnsafeMemory $1 8 105 128
echo "---"
echo "n_threads = 16"
# n_threads = 16
echo "nVals = 32"
time java UnsafeMemory $1 16 100 32
time java UnsafeMemory $1 16 101 32
time java UnsafeMemory $1 16 102 32
time java UnsafeMemory $1 16 103 32
time java UnsafeMemory $1 16 104 32
time java UnsafeMemory $1 16 105 32
echo "nVals = 64"
time java UnsafeMemory $1 16 100 64
time java UnsafeMemory $1 16 101 64
time java UnsafeMemory $1 16 102 64
time java UnsafeMemory $1 16 103 64
time java UnsafeMemory $1 16 104 64
time java UnsafeMemory $1 16 105 64
echo "nVals = 128"
time java UnsafeMemory $1 16 100 128
time java UnsafeMemory $1 16 101 128
time java UnsafeMemory $1 16 102 128
time java UnsafeMemory $1 16 103 128
time java UnsafeMemory $1 16 104 128
time java UnsafeMemory $1 16 105 128
echo "---"
echo "n_threads = 32"
# n_threads = 32
echo "nVals = 32"
time java UnsafeMemory $1 32 100 32
time java UnsafeMemory $1 32 101 32
time java UnsafeMemory $1 32 102 32
time java UnsafeMemory $1 32 103 32
time java UnsafeMemory $1 32 104 32
time java UnsafeMemory $1 32 105 32
echo "nVals = 64"
time java UnsafeMemory $1 32 100 64
time java UnsafeMemory $1 32 101 64
time java UnsafeMemory $1 32 102 64
time java UnsafeMemory $1 32 103 64
time java UnsafeMemory $1 32 104 64
time java UnsafeMemory $1 32 105 64
echo "nVals = 128"
time java UnsafeMemory $1 32 100 128
time java UnsafeMemory $1 32 101 128
time java UnsafeMemory $1 32 102 128
time java UnsafeMemory $1 32 103 128
time java UnsafeMemory $1 32 104 128
time java UnsafeMemory $1 32 105 128