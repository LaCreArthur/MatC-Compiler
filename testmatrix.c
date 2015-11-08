#include <stdio.h>
#include "matrix.h"
#include <stdlib.h>

void test() {

	matrix m = matrix_new(2,3);
	matrix_set(&m,0,0,1);
	matrix_set(&m,0,1,2);
	matrix_set(&m,0,2,3);
	matrix_set(&m,1,0,4);
	matrix_set(&m,1,1,5);
	matrix_set(&m,1,2,6);
	printf("matrix m = \n");
	matrix_print(m);

	// transpos test *********************** ok
	// printf("matrix_transpos : \n");
	// matrix m1 = matrix_transpos(m);
	// matrix_print(m1);
	//
	// // add and sub test ******************** ok
	// matrix m2 = matrix_new(2,2);
	// matrix_set(&m2,0,0,1);
	// matrix_set(&m2,0,1,2);
	// matrix_set(&m2,1,0,3);
	// matrix_set(&m2,1,1,4);
	// printf("matrix_+: m2 + m2 \n");
	// matrix_print(m2);
	// matrix m3 = matrix_addOrSub(m2,m2,'+');
	// matrix_print(m3);
	// printf("matrix_-: m2 - m2\n");
	// m3 = matrix_addOrSub(m2,m2,'-');
	// matrix_print(m3);
	//
	// // tester mult and div ***************** ok
	// matrix m4 = matrix_new(3,2);
	// matrix_set(&m4,0,0,1);
	// matrix_set(&m4,0,1,4);
	// matrix_set(&m4,1,0,2);
	// matrix_set(&m4,1,1,5);
	// matrix_set(&m4,2,0,3);
	// matrix_set(&m4,2,1,6);
	// printf("matrix_* : m * m4 \n");
	// matrix_print(m);
	// matrix_print(m4);
	// matrix m5 = matrix_multOrDiv(m,m4,'*');
	// matrix_print(m5);
	//
	// // test constVal ************************ ok
	// matrix m6 = matrix_new(2,3);
	// printf("matrix_constOp : m / 2 : \n");
	// m6 = matrix_constOp(m,2.,'/');
	// matrix_print(m6);

	// test matrix_extrac ******************* ok
	int t1[2] = {0,1};
	int t2[1] = {2};

	matrix m7 = matrix_extract(m,2,t1,1,t2);
	matrix_print(m7);
	free(m.mat);
	// free(m1.mat);
	// free(m2.mat);
	// free(m3.mat);
	// free(m4.mat);
	// free(m5.mat);
	// free(m6.mat);
	free(m7.mat);
}
