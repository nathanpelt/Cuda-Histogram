# Cuda Histogram

To test code you will an Nvidia video card and an IDE, I used Emacs

This code is written with Cuda and C. It efficiently runs a histogram algorithm in parallel on an nvidia gpu.
The size of the blocks is determined by size of the input file. The atomicAdd() function adds up sum of all the threads subparts.
