package group8;

import java.util.*;
import java.io.*;
import com.jopdesign.sys.Const;
import com.jopdesign.sys.Native;
import joprt.RtThread;


public class PacketSender{
	
	public static int pollReCOPResponse(){
		int datacallWord = 0;
		System.out.println("Started Polling response");

		while(true){
			datacallWord = Native.getDatacall();

			if ((datacallWord & (1 << 31)) != 0){  // Valid
				System.out.println("Response Recieved: " + int2hexString(datacallWord & 0xFFFF));
				return datacallWord;
			}
		}
	}

	public static String int2hexString(int dec){
		char[] hexDigits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
		String hex = "";
		int rem;

		while (dec != 0) {
			rem = dec % 16;
			hex = hexDigits[rem] + hex;
			dec = dec / 16;
		}
		return hex;
	}

	public static String int2hexString(long dec){
		char[] hexDigits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
		String hex = "";
		long rem;

		while (dec != 0) {
			rem = dec % 16;
			hex = hexDigits[(int)rem] + hex;
			dec = dec / 16;
		}
		return hex;
	}


	public static void main(String args[]){
		int[] arrayA = {0xECE, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777};
		int[] arrayB = {0x0, 0x99, 0x101, 0x103, 0x105, 0x107, 0x109, 0x0};

		int dataResult;
		long dataResultLong;

		int dataCallReCOP;

		while(true){
			dataCallReCOP = pollReCOPResponse() & 0xFFFF;

			switch (dataCallReCOP) {
				case 0xAAA:

					dataResult = ASPCommunication.store(arrayB, 0, 1);  // Store array to B on ASP

					if ((dataResult & 0xFFFF) == 1){
						System.out.println("Store B success");
					} else {
						System.out.println("ERROR: Store failed");
					}
					SevenSeg.writeToSevenSegHex(dataResult);  // write access granted to 7 seg


					RtThread.sleepMs(2000);  // sleep for 2 sec


					dataResult = ASPCommunication.xor(1, 0, 7) & 0xFFFF;  // XOR B 0 to 7, expect 400 (0x190)
					
					System.out.println("XOR res = " + dataResult + " = 0x" + int2hexString(dataResult));
					SevenSeg.writeToSevenSegHex(dataResult);  // 190 should be printed

					RtThread.sleepMs(2000);  // sleep for 2 sec

					ASPCommunication.sendPacket(0x80000003);  // reply back to ReCOP 0


					break;

				case 0xBBB:
					dataResult = ASPCommunication.ave(4, 1);  // AVE B, Window size = 4

					if ((dataResult & 0xFFFF) == 1){
						System.out.println("AVE success");
					} else {
						System.out.println("ERROR: AVE failed");
					}
					SevenSeg.writeToSevenSegHex(dataResult);  // write access granted to 7 seg


					RtThread.sleepMs(2000);  // sleep for 2 sec


					dataResult = ASPCommunication.store(arrayA, 0, 0);  // Store array to A on ASP

					if ((dataResult & 0xFFFF) == 1){
						System.out.println("Store A success");
					} else {
						System.out.println("ERROR: Store failed");
					}
					SevenSeg.writeToSevenSegHex(dataResult);  // write access granted to 7 seg



					dataResultLong = ASPCommunication.mac(0, 511);  // MAC 0 to 511

					System.out.println("MAC res = " + dataResultLong + " = 0x" + int2hexString(dataResultLong));
					SevenSeg.writeToSevenSegHex((int)dataResultLong);  // 190 should be printed

					break;

				case 0xCCC:
					//Doing Matrix multiplication
					// Values from lab 3
	
					matrix.C = new Integer[matrix.A.length][matrix.B[0].length];
					
					
					// Initialising C
					for (int i = 0; i < matrix.C.length; i++){
						for (int j = 0; j < matrix.C[0].length; j++){
							matrix.C[i][j] = 0;
						}
					}
					
					System.out.println("A = ");
					matrix.print_matrix(matrix.A);
					
					System.out.println("B = ");
					matrix.print_matrix(matrix.B);
					
					if (A[0].length != matrix.B.length){
						System.out.println("Error: number of columns in A does not match the number of rows in B.");
					}
					
					SysDevice sys = IOFactory.getFactory().getSysDevice();

					for(int i = 0 ; i < sys.nrCpu-1;i++){
						Runnable r = new matrix(i+1);
						Startup.setRunnable(r,i);
					}

					//do the first row
					matrix.matrix_mult(matrix.A[0],0,matrix.B,matrix.C);

					sys.signal = 1;


					//wait for other JOPs to finish
					RtThread.sleepMs(1000);

					System.out.println("A x B = ");
					matrix.print_matrix(matrix.C);
					
					System.out.println("END");

					break;

				default:
					System.out.println("Unknown datacall code");

					break;
			}
		}



	}
}