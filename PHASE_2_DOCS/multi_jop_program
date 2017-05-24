# Multi-JOP Java Program

## Description

A simple multi-jop java program was developed to perform a simple matrix multiplication:

$$\textbf{A} \times \textbf{B} = \textbf{C}$$

where:

$$\textbf{A} = \begin{pmatrix}	2&3&5&2&3\\	3&2&3&4&1 \\ 2&3&1&2&3	\end{pmatrix}$$

$$\textbf{B} = \begin{pmatrix} 1&2 \\ 2&3 \\ 6&5 \\ 1&2 \\ 2&2 \end{pmatrix}$$

$$\textbf{C} = \begin{pmatrix} 46&48 \\ 31&37 \\22&28 \end{pmatrix}$$

One JOP will perform a row of matrix multiplication. 

Therefore for $JOP_i, i \in [0,2]$, the calculations it will perform are:

$$\sum\limits_{j=0}^{L}\textbf{C}_{ij} = \sum\limits_{k=0}^{N} \textbf{A}_{ki} \times \textbf{B}_{jk}$$

Where $L$ is the number of columns of $\textbf{C}$, and $N$ is the number of columns of $\textbf{A}$. Notice the number of rows of $\textbf{B}$ is equal to $N$ as well.





```java
package test;

import java.util.Vector;

import joprt.RtThread;

import com.jopdesign.io.IOFactory;
import com.jopdesign.io.SysDevice;
import com.jopdesign.sys.Startup;

public class matrix implements Runnable{


	Integer matA[][];
	Integer matB[][];
	Integer matC[][];

	static Vector msg;
	public static Integer[][] A= {{2, 3, 5, 2, 3}, {3, 2, 3, 4, 1}, {2, 3, 1, 2, 3}}; ;
	public static Integer[][] B= {{1, 2}, {2, 3}, {6, 5}, {1, 2}, {2, 2}};;
	public static Integer[][] C;
	int cpu_id;
	// Matrix multiplication for one row.
	public static void matrix_mult(Integer[] row, int row_num, Integer[][] cols, Integer[][] C){
		int i, j;
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


	
	public matrix(int identity){
		cpu_id = identity;
	}
	
	
	public static void main(String[] args) {
		
		
		// Values from lab 3
	
		C = new Integer[A.length][B[0].length];
		
		msg = new Vector();
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
			Runnable r = new matrix(i+1);
			Startup.setRunnable(r,i);
		}

		//do the first row
		matrix_mult(A[0],0,B,C);

		sys.signal = 1;


		//wait for other JOPs to finish
		RtThread.sleepMs(1000);

		System.out.println("A x B = ");
		print_matrix(C);
		
		System.out.println("END");
		
	}

	public void run(){
		matrix_mult(A[cpu_id],cpu_id,B,C);
	}



}
```

