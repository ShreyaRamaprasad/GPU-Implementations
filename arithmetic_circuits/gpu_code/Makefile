#Makefile 
#define variables
objects= main.o kernels.o 
NVCC= /usr/local/cuda-9.1/bin/nvcc               #cuda c compiler
opt= -O2 -g -G           #optimization flag
ARCH= -arch=sm_30        #cuda compute capability
LIBS= 
execname= main



#compile
$(execname): $(objects)
	$(NVCC) $(opt) -o $(execname) $(objects) $(LIBS) 

kernels.o: kernels.cu
	$(NVCC) $(opt) $(ARCH) -c -l/usr/local/cuda-9.1/include kernels.cu
main.o: main.cu
	$(NVCC) $(opt) $(ARCH) -std=c++11 -c -l/usr/local/cuda-9.1/include main.cu


#clean Makefile
clean:
	rm $(objects)
#end of Makefile

