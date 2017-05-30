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


