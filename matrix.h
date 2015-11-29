#ifndef __MATR__H__
#define __MATR__H__

typedef struct mat{
	float *mat;
	int rows;
	int cols;
} matrix;

typedef struct arr{
	int size;
	float *values;
	int* dims;
	int D;
} array;

matrix matrix_new			 (int rows, int cols);
matrix matrix_transpos (matrix a);
matrix matrix_addOrSub (matrix a, matrix b, char op);
matrix matrix_multOrDiv(matrix a, matrix b, char op);
matrix matrix_constOp	 (matrix a, float constVal, char op);
matrix matrix_extract	 (matrix a, int row, int* rows, int col, int* cols);

void matrix_set		(matrix *m, int row, int col, float nb);
void matrix_print (matrix m);
void matrix_free	(matrix* m);

// copie the temp float array in reverse order and return it
float* arr_cpy_tmp(float* tmp, int size);
int array_dimsToSize(int* dims, int D);
array* array_new(int* dims, int D);
void array_print(float* arr, FILE* out);
void array_fillWithZero(array* arr, int count);

#endif
