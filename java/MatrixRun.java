package matrix_mult;

public class MatrixRun {
	private Integer A[][] = {{2, 3, 5, 2, 3}, {3, 2, 3, 4, 1}, {2, 3, 1, 2, 3}}; 
	private Integer B[][] = {{1, 2}, {2, 3}, {6, 5}, {1, 2}, {2, 2}};
	private Integer[][] C = new Integer[A.length][B[0].length];



	public static void main(String[] args) {
		
		// Initialising C
		for (int i = 0; i < C.length; i++){
			for (int j = 0; j < C[0].length; j++){
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
		
		SysDevice sys = IOFactory.getFactory().getSysDevice();

		for(int i = 0 ; i < sys.nrCpu-1;i++){
			Runnable r = new marix(i);
			Startup.setRunnable(r,i);
		}

		// // Allowcating each row to a JOP
		// for (i = 0; i < A.length; i++){
			
		// 	// Insert specific JOP call
		// 	matrix_mult(A[i], i, B, C);
		// }
		
		System.out.println("A x B = ");
		print_matrix(C);
		
		System.out.println("END");
	}
}