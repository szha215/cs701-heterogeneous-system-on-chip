package group8;

import java.util.*;
import java.io.*;
import com.jopdesign.sys.Const;
import com.jopdesign.sys.Native;
import joprt.RtThread;

import com.jopdesign.io.IOFactory;
import com.jopdesign.io.SysDevice;
import com.jopdesign.sys.Startup;
import util.Timer;

public class PacketSender{
	

	public static int getTimeUS(){
		return Native.rd(Const.IO_US_CNT);
	}


	public static void printTimingResult(String item,int startTime, int endTime){
		System.out.println("\n" + item + " timing result: " + (endTime - startTime) + "us\n");
	}

	public static void sendReCOPPacket(int packet){
		System.out.println("Replying back to ReCOP...");
		Native.setDatacallResult(packet);
	}

	public static int pollReCOPResponse(){
		int datacallWord = 0;
		System.out.println("Started Polling for Response");

		while(true){
			datacallWord = Native.getDatacall();

			if ((datacallWord & (1 << 31)) != 0){  // Valid
				System.out.println("Response Recieved: 0x" + int2hexString(datacallWord & 0xFFFF) + " = " + (datacallWord & 0xFFFF));
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

	public static void aveJOP(int[] vec, int windowSize){
		int[] temp = new int[vec.length];
		int sum;

		for (int i = 0; i+windowSize-1 < vec.length; i++){
			sum = 0;

			for (int j = 0; j < windowSize; j++){
				sum += vec[i+j];
			}

			temp[i] = sum / windowSize;
		}
	}


	public static int xorJOP(int[] vecA){
		int xorResult = 0;

		for(int i = 0; i < vecA.length; i++){
			xorResult ^= vecA[i]; 
		}

		return xorResult;
	}

	public static int xorJOP(int[] vecA, int end){
		int xorResult = 0;

		for(int i = 0; i < end; i++){
			xorResult ^= vecA[i]; 
		}

		return xorResult;
	}

	public static long macJOP(int[] vecA, int[] vecB){
		long macResult = 0;

		for(int i = 0 ; i < vecA.length; i++){
			macResult += (vecA[i]*vecB[i]);
		}

		return macResult;
	}

	public static long macJOP(int[] vecA, int[] vecB, int end){
		long macResult = 0;

		for(int i = 0; i < end; i++){
			macResult += (vecA[i] * vecB[i]);
		}

		return macResult;
	}

	public static void main(String args[]){
		int[] arrayA = {0xECE, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777};
		int[] arrayB = {0x0, 0x99, 0x101, 0x103, 0x105, 0x107, 0x109, 0x0};

		int dataResult;
		long dataResultLong;

		int dataCallReCOP;
		int startTime = 0;
		int endTime = 0;
		while(true){
			System.out.println("\n=============== Awaiting ReCOP ===============");
			dataCallReCOP = pollReCOPResponse() & 0xFFFF;

			switch (dataCallReCOP) {
				case 1111:
					//Doing Matrix multiplication
					// Values from lab 3
					
					System.out.println("\n>> START MATRIX MULTIPLICATION");

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
					
					if (matrix.A[0].length != matrix.B.length){
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
					RtThread.sleepMs(500);

					System.out.println("A x B = ");
					matrix.print_matrix(matrix.C);
					
					System.out.println("END");

					break;

				case 2222:
					System.out.println("\n>> Storing into array B");
					dataResult = ASPCommunication.store(0, arrayB, 0, 1);  // Store array to B on ASP

					SevenSeg.writeToSevenSegHex(dataResult);  // write access granted to 7 seg

					System.out.println("\n>> XOR B");

					dataResult = ASPCommunication.xor(0, 1, 0, 7) & 0xFFFF;  // XOR B 0 to 7, expect 400 (0x190)

					System.out.println("ASP XOR res = " + dataResult + " = 0x" + int2hexString(dataResult));
					SevenSeg.writeToSevenSegHex(dataResult);  // 190 should be printed
					startTime = getTimeUS();
					RtThread.sleepMs(500); 
					endTime = getTimeUS();
					printTimingResult("Sleep",startTime,endTime);
					sendReCOPPacket(0x80000003);  // reply back to ReCOP 0

					break;

				case 3333:
					System.out.println("\n>> Storing into array A");
					dataResult = ASPCommunication.store(0, arrayA, 0, 0);  // Store array to A on ASP

					SevenSeg.writeToSevenSegHex(dataResult);  // write access granted to 7 seg

					RtThread.sleepMs(500); 

					System.out.println("\n>> MAC");
					dataResultLong = ASPCommunication.mac(0, 0, 511);  // MAC 0 to 511

					System.out.println("MAC res = " + dataResultLong + " = 0x" + int2hexString(dataResultLong));
					SevenSeg.writeToSevenSegHex((int)dataResultLong);  // 167721 should be printed

					RtThread.sleepMs(500); 

					System.out.println("\n>> AVE B, Window = 4");
					startTime = getTimeUS();
					dataResult = ASPCommunication.ave(0, 4, 1);  // AVE B, Window size = 4

					if ((dataResult & 0xFFFF) == 1){
						System.out.println("AVE success");
					} else {
						System.out.println("ERROR: AVE failed");
					}
					endTime = getTimeUS();
					printTimingResult("AVE_ASP",startTime,endTime);	


				

					SevenSeg.writeToSevenSegHex(dataResult);  // write access granted to 7 seg


					RtThread.sleepMs(500); 

					System.out.println("\n>> MAC");
					dataResultLong = ASPCommunication.mac(0, 0, 511);  // MAC 0 to 511

					System.out.println("MAC res = " + dataResultLong + " = 0x" + int2hexString(dataResultLong));
					SevenSeg.writeToSevenSegHex((int)dataResultLong);  // 17BEF8 should be printed

					break;

				case 4444:  
					System.out.println("\n>> JOP vs ASP Performance test");

					int numWords = 512;
					int[] multiA, multiB;
					multiA = new int[numWords];
					multiB = new int[numWords];
					long macResultJOP = 0;
					long macResultASP = 0;
					int  xorResultJOP = 0;
					int aveASP = 0;
					int aveJOP = 0;
					Random rand = new Random();

					for (int i = 0; i < numWords; i++){
						multiA[i] = rand.nextInt();
						multiB[i] = rand.nextInt();
					}

					System.out.println("Storing into ASPs...");

					ASPCommunication.store(0, multiA, 0, 0);  // Store ASP 0, A
					int storeTime = ASPCommunication.store(0, multiB, 0, 1);  // Store ASP 0, B

					System.out.println("==============================================================64");	
					



					startTime = getTimeUS();
					macResultJOP = macJOP(multiA,multiB,64);
					endTime = getTimeUS();
					printTimingResult("MAC_JOP_64",startTime,endTime);

					startTime = getTimeUS();
					macResultASP = ASPCommunication.mac(0,0,63);
					endTime = getTimeUS();
					printTimingResult("MAC_ASP_64",startTime,endTime);
					

					System.out.println("==================");

					startTime = getTimeUS();
					xorResultJOP = xorJOP(multiA,64);
					endTime = getTimeUS();
					printTimingResult("XOR_JOP_64",startTime,endTime);

					startTime = getTimeUS();					
					dataResult = ASPCommunication.xor(1, 0, 0, 63);
					endTime = getTimeUS();
					printTimingResult("XOR_ASP_1",startTime,endTime);
					System.out.println("ASP 1 XOR res = " + (dataResult & 0xFFFF));


					System.out.println("==============================================================128");	
					


					startTime = getTimeUS();
					macResultJOP = macJOP(multiA,multiB,128);
					endTime = getTimeUS();
					printTimingResult("MAC_JOP_128",startTime,endTime);

					startTime = getTimeUS();
					macResultASP = ASPCommunication.mac(0,0,127);
					endTime = getTimeUS();
					printTimingResult("MAC_ASP_128",startTime,endTime);
					

					System.out.println("==================");

					startTime = getTimeUS();
					xorResultJOP = xorJOP(multiA,128);
					endTime = getTimeUS();
					printTimingResult("XOR_JOP_128",startTime,endTime);

					startTime = getTimeUS();					
					dataResult = ASPCommunication.xor(1, 0, 0, 127);
					endTime = getTimeUS();
					printTimingResult("XOR_ASP_1",startTime,endTime);
					System.out.println("ASP 1 XOR res = " + (dataResult & 0xFFFF));


					System.out.println("==============================================================256");	
					




					startTime = getTimeUS();
					macResultJOP = macJOP(multiA,multiB,256);
					endTime = getTimeUS();
					printTimingResult("MAC_JOP_256",startTime,endTime);

					startTime = getTimeUS();
					macResultASP = ASPCommunication.mac(0,0,255);
					endTime = getTimeUS();
					printTimingResult("MAC_ASP_256",startTime,endTime);
					

					System.out.println("==================");

					startTime = getTimeUS();
					xorResultJOP = xorJOP(multiA,256);
					endTime = getTimeUS();
					printTimingResult("XOR_JOP_256",startTime,endTime);

					startTime = getTimeUS();					
					dataResult = ASPCommunication.xor(1, 0, 0, 255);
					endTime = getTimeUS();
					printTimingResult("XOR_ASP_256",startTime,endTime);
					System.out.println("ASP 1 XOR res = " + (dataResult & 0xFFFF));


					System.out.println("==============================================================512");	
					System.out.println("\nStore Time: " + storeTime + "us\n");

					System.out.println("==================");
					startTime = getTimeUS();
					aveJOP(multiB,4);
					endTime = getTimeUS();
					printTimingResult("AVE_JOP_512_4", startTime,endTime);


					startTime = getTimeUS();
					aveASP = ASPCommunication.ave(0,4,0);
					endTime = getTimeUS();
					printTimingResult("AVE_ASP_512_4", startTime, endTime);


					System.out.println("==================");
					startTime = getTimeUS();
					aveJOP(multiB,8);
					endTime = getTimeUS();
					printTimingResult("AVE_JOP_512_8", startTime,endTime);


					startTime = getTimeUS();
					aveASP = ASPCommunication.ave(0,8,0);
					endTime = getTimeUS();
					printTimingResult("AVE_ASP_512_8", startTime, endTime);


					System.out.println("==================");

					startTime = getTimeUS();
					macResultJOP = macJOP(multiA,multiB);
					endTime = getTimeUS();
					printTimingResult("MAC_JOP_512",startTime,endTime);

					startTime = getTimeUS();
					macResultASP = ASPCommunication.mac(0,0,numWords-1);
					endTime = getTimeUS();
					printTimingResult("MAC_ASP_512",startTime,endTime);
					

					System.out.println("==================");

					startTime = getTimeUS();
					xorResultJOP = xorJOP(multiA);
					endTime = getTimeUS();
					printTimingResult("XOR_JOP_512",startTime,endTime);

					startTime = getTimeUS();					
					dataResult = ASPCommunication.xor(1, 0, 0, numWords - 1);
					endTime = getTimeUS();
					printTimingResult("XOR_ASP_1",startTime,endTime);
					System.out.println("ASP 1 XOR res = " + (dataResult & 0xFFFF));

					System.out.println("================= DONE ==================");

					break;

				default:
					System.out.println("Unknown datacall code, " + Integer.toBinaryString(dataCallReCOP));
					break;
			}
		}



	}
}