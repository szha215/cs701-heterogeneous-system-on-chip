package matrix_mult;

public class matrix {

	// Matrix multiplication for one row.
	public static void matrix_mult(Integer[] row, int row_num, Integer[][] cols, Integer[][] C){
		int i, j;
		
		System.out.println("Mat_mult, row = " + row_num);
		
		for (i = 0; i < cols[0].length; i++){
			for (j = 0; j < row.length; j++){
				C[row_num][i] += row[j] * cols[j][i];
			}
		}
	}
	
	public static void print_matrix(Integer[][] mat){
		int i, j;
		
		for (i = 0; i < mat.length; i++){
			for (j = 0; j < mat[0].length; j++){
				System.out.print(mat[i][j] + "\t");
			}
			System.out.print("\n");
		}
		
		System.out.println("------------------------");
	}
	
	
	public static void main(String[] args) {
		int i, j;
		
		// Values from lab 3
		Integer A[][] = {{2, 3, 5, 2, 3}, {3, 2, 3, 4, 1}, {2, 3, 1, 2, 3}}; 
		Integer B[][] = {{1, 2}, {2, 3}, {6, 5}, {1, 2}, {2, 2}};
		
		Integer[][] C = new Integer[A.length][B[0].length];
		
		// Initialising C
		for (i = 0; i < C.length; i++){
			for (j = 0; j < C[0].length; j++){
				C[i][j] = 0;
			}
		}
		
		System.out.println("A = ");
		print_matrix(A);
		
		System.out.println("B = ");
		print_matrix(B);
		
		if (A[0].length != B.length){
			System.out.println("Error: number of columns in A does not match the number of rows in B.");
		}
		
		// Allowcating each row to a JOP
		for (i = 0; i < A.length; i++){
			
			// Insert specific JOP call
			matrix_mult(A[i], i, B, C);
		}
		
		System.out.println("A x B = ");
		print_matrix(C);
		
		System.out.println("END");
	}

}
