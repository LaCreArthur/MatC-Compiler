typedef struct mat{
	float *mat;
	int rows;
	int cols;
} matrix;

matrix matrix_new(int rows, int cols);
void matrix_set(matrix *m, int row, int col, float nb);
void matrix_print (matrix m);
matrix matrix_transpos(matrix a);
matrix matrix_addOrSub(matrix a, matrix b, char op);
matrix matrix_multOrDiv(matrix a, matrix b, char op);
matrix matrix_constOp(matrix a, float constVal, char op);
matrix matrix_extract(matrix a, int row, int* rows, int col, int* cols);
void matrix_free(matrix* m);
