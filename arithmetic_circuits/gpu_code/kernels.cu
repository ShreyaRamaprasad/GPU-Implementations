#include "kernels.cuh"

struct node {
  char nodeType; 
  int index;
  double vr; 
  double dr; 
  int child[2];
  bool flag;
};



__global__ void build_circuit(struct node** array, int n, int H, int *num)
{

	unsigned int index = threadIdx.x + blockIdx.x*blockDim.x;
        unsigned int stride = gridDim.x*blockDim.x;
        unsigned int offset = 0;

	//__shared__ float cache[256];

	int start = 0, end = 0, diff = 0;

	//array of length n with nodes in level order
	struct node* parent = (struct node*)malloc(sizeof(struct node));
        for(int h=0;h<H;h++){
		start = h == 0 ? 0 : h*num[h-1];
		end = start + num[h];
		diff = end - start;
		while(index + offset < diff) {
        	//1 thread should work on multiple nodes
		parent = array[start+index+offset];

		/*Assign dr values depending on parent node*/
		if (parent->nodeType == '+') {
			array[parent->child[0]]->dr = parent->dr;
			array[parent->child[1]]->dr = parent->dr;
		}
		else if (parent->nodeType == '*') {
		/*if bit flag is down, and parent is non-zero, dr(c) = dr(p)*vr(p)/vr(c)*/
			if (parent->dr == 0) {
			//if (cache[start+index+offset] == 0) {
				/*Set all child nodes dr to zero*/
				array[parent->child[0]]->dr = 0;
				array[parent->child[1]]->dr = 0;
			}
			else if (parent->flag) {
				/*Check value of all child nodes*/
				/*if flag is up and child is zero, then dr(c) = dr(p) * vr(p)*/
				if (array[parent->child[0]]->vr == 0) {
					array[parent->child[0]]->dr = parent->dr * parent->vr;
					/*Set all other children dr to zero*/
					array[parent->child[1]]->dr = 0;
				}
        			else {
					array[parent->child[1]]->dr = 0;
					array[parent->child[0]]->dr = parent->dr *
                        		(parent->vr / array[parent->child[0]]->vr);
				}
			}
			else {
				array[parent->child[1]]->dr = parent->dr *
                		(parent->vr / array[parent->child[1]]->vr);
				array[parent->child[0]]->dr = parent->dr *
                		(parent->vr / array[parent->child[0]]->vr);
			}
		}
		//testing code
		//cache[parent->child[0]] = array[parent->child[0]]->dr;
		//cache[parent->child[1]] = array[parent->child[1]]->dr;
		offset += stride;
	}
	__syncthreads();
}
}
