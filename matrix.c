#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"

matrix matrix_new(int rows, int cols){
	matrix new;
	new.mat = (float*) malloc (rows*cols*sizeof(float));
	new.rows = rows;
	new.cols = cols;
	return new;
}

int array_dimsToSize(int* dims, int D){
	int size = 1;
	for (int i=0; i<D; i++){
		size*=dims[i];
	}
	return size;
}

array* array_new(int* dims, int D){
	array* new = malloc(sizeof(*new));
	int size = array_dimsToSize(dims, D);
	new->size = size;
	// new->values = malloc(size*sizeof(float));
	// new->values = values; // must be malloc in amont
	// printf("%s %f\n", "array values[0] : ", values[0]);
	// printf("%s %f\n", "array new values[0] : ", new->values[0]);
	new->D = D;
	new->dims = dims;
	return new;
}

void matrix_set(matrix *m, int row, int col, float nb){
	m->mat[(m->cols)*row + col] = nb;
}

void matrix_print(matrix m){
	int i,j;
	for (i=0; i<m.rows; i++){
		for(j=0; j<m.cols; j++) {
			printf("%f\t", m.mat[i*m.cols+j]);
		}
		printf("\n");
	}
	printf("\n");
}

void array_print(float* arr, FILE* out) {
  unsigned int i;
  for(i=0; i < (sizeof(arr)/sizeof(float)) ; i++){
		fprintf(out,"%.2f, ",arr[i]);
  }
  fprintf(out,"%.2f\n",arr[i]);
}

matrix matrix_transpos(matrix m) {
	matrix trans = matrix_new(m.cols, m.rows);
	for (int i=0; i<m.cols; i++){
		for(int j=0; j<m.rows; j++) {
			matrix_set(&trans, i, j, m.mat[j*m.cols+i]);
		}
	}
	return trans;
}

matrix matrix_addOrSub(matrix a, matrix b, char op){
	int n = a.cols
		, m = a.rows
		, p = b.rows;

	matrix res = matrix_new(n,m);
	if (n != b.rows || m != p) {
		fprintf(stderr, "Matrices need to be A(n,m)+B(m,p), and they are A(%d,%d)+B(%d,%d)\n" ,n,m,b.cols,p);
		exit(EXIT_FAILURE);
	}
	for (int i=0; i<n; i++){
		for(int j=0; j<p; j++) {
			switch (op) {
				case '-': { matrix_set(&res,i,j,(a.mat[i*n+j] - b.mat[i*n+j])); break;}
				case '+': { matrix_set(&res,i,j,(a.mat[i*n+j] + b.mat[i*n+j])); break;}
				default : { fprintf(stderr, "matrix_addOrSub unknow operator : %c", op);
										exit(EXIT_FAILURE); }
			}
		}
	}
	return res;
}

matrix matrix_multOrDiv(matrix a, matrix b, char op){
	int n = a.rows
		, m = a.cols
		, p = b.cols;
	float nb;

	matrix res = matrix_new(n,p);
	if (m != b.rows) {
		fprintf(stderr, "Matrices need to be A(n,m)*B(m,p), and they are A(%d,%d)*B(%d,%d)\n",n,m,b.rows,p);
		exit(EXIT_FAILURE);
	}

	for (int i=0; i<n; i++){
		for(int j=0; j<p; j++){
			nb= 0. ;
			for(int k=0; k<m; k++)
				switch (op) {
					case '*': { // printf("calc (%d,%d): %f + %f * %f \n",i,j, nb, a.mat[i*n + k], b.mat[k*m + j]); // ok
											nb = nb + (a.mat[i*m + k] * b.mat[k*p + j]); break;}
					case '/': { nb = nb + (a.mat[i*m + k] / b.mat[k*p + j]); break;}
					default : { fprintf(stderr, "matrix_multOrDiv unknow operator : %c", op);
											exit(EXIT_FAILURE); }
				}
			matrix_set(&res,i,j,nb);
		}
	}
	return res;
}

matrix matrix_constOp(matrix a, float constVal, char op){
	matrix res = matrix_new(a.rows, a.cols);
	float nb;
	for (int i =0; i<a.rows; i++){
		for (int j=0; j<a.cols; j++){
			nb = 0. ;
			switch (op) {
				case '+': { nb = a.mat[i*a.cols+j] + constVal; break;}
				case '-': { nb = a.mat[i*a.cols+j] - constVal; break;}
				case '*': { nb = a.mat[i*a.cols+j] * constVal; break;}
				case '/': { nb = a.mat[i*a.cols+j] / constVal; break;}
				default : { fprintf(stderr, "matrix_constOp unknow operator : %c", op);
										exit(EXIT_FAILURE); }
			}
			matrix_set(&res, i, j, nb);
		}
	}
	return res;
}

matrix matrix_extract(matrix a, int row, int* rows, int col, int* cols){
	matrix res = matrix_new(row,col);

	if (res.rows <= res.cols) {
		for (int i =0; i<res.rows; i++){
			for (int j=0; j<res.cols; j++){
				matrix_set(&res, i,j, a.mat[rows[i]*a.cols+cols[j]]);
			}
		}
	} else {
		for (int j=0; j<res.cols; j++){
			for (int i =0; i<res.rows; i++){
				matrix_set(&res, i,j, a.mat[rows[i]*a.cols+cols[j]]);
			}
		}
	}
	return res;
}

void matrix_free(matrix* m){
	free(m->mat);
	free(m);
}

float* arr_cpy_tmp(float* tmp, int size){
  float* res = malloc(size * sizeof(float));
  int j= size-1;
  for(int i=0; i<size ; i++){
    res[j] = tmp[i]; // tmp is backward recorded
		//printf("arrcpy %d val: %.2f\n",j,tmp[i]);
    j--;
  }
  return res;
}
