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
				System.out.println("Response Recieved: " + int2hexString(datacallWord));
				return datacallWord;
			}
		}
	}


	public static String int2hexString(int dec){
		char[] hexDigits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
		String hex = "";
		while (dec != 0) {
			int rem = dec % 16;
			hex = hexDigits[rem] + hex;
			dec = dec / 16;
		}
		return hex;
	}


	public static void main(String args[]){
		// PacketConstructor pkt = new PacketConstructor(OPCODE.OP.STORE1,0x0,0x0,0x1,0x8);
		// PacketConstructor dataPkt = new PacketConstructor(0x0,0x0,0x1,0x99);
		// int[] StoreArr = {0x0, 0x99,0x101,0x103,0x105,0x107,0x109, 0x0};
		// int jop_xor = 0;

		// int datacallWord = 0;
		// int datacallWordASP = 0;
		// //poll recop datacall
		// datacallWord = pollResponse() & 0xFFFF;

		// System.out.println(datacallWord);
		// if(datacallWord == 0xAAA){
		// 	sendPacket(pkt.getPacket());
		// }
		
		// for(int i = 0; i < StoreArr.length; i++){
		// 	jop_xor = jop_xor ^ StoreArr[i];
		// 	dataPkt.updatePacket(0x0,0x0,i,StoreArr[i]);
		// 	sendPacket(dataPkt.getPacket());
		// }

		// datacallWordASP = pollResponse() & 0xFFFF;


		// System.out.println(datacallWordASP);
		// SevenSeg.writeToSevenSegDec(datacallWordASP);

		// System.out.println("Sending XOR command...");
		// pkt.updatePacket(OPCODE.OP.XORB,0x0,0x0,0x7,0x0);
		// sendPacket(pkt.getPacket());


		// datacallWordASP = pollResponse() & 0xFFFF;
		// System.out.println("JOP XOR = " + jop_xor + " = 0x" + int2hexString(jop_xor));
		// System.out.println("ASP XOR = " + datacallWordASP + " = 0x" + int2hexString(datacallWordASP));
		// SevenSeg.writeToSevenSegDec(datacallWordASP);


		// sendPacket(0x80000003);  // reply back to ReCOP

		// datacallWord = pollResponse() & 0xFFFF; // wait for new ReCOP datacall

		// System.out.println("New ReCOP datacall = 0x" + int2hexString(datacallWord));


		int[] storeArr = {0x0, 0x99,0x101,0x103,0x105,0x107,0x109, 0x0};

		int dataResult;

		if ((pollReCOPResponse() & 0xFFFF) == 0xAAA){

			dataResult = ASPCommunication.store(storeArr, 0, 1);  // Store array to B on ASP

			if ((dataResult & 0xFFFF) == 1){
				System.out.println("Store success");
			} else {
				System.out.println("ERROR: Store failed");
			}
			SevenSeg.writeToSevenSegHex(dataResult);  // write access granted to 7 seg


			RtThread.sleepMs(2000);  // sleep for 2 sec


			dataResult = ASPCommunication.xor(1, 0, 7) & 0xFFFF;  // XOR B 0 to 7, expect 400 (0x190)
			
			System.out.println("XOR res = " + dataResult + " = 0x" + int2hexString(dataResult));
			SevenSeg.writeToSevenSegHex(dataResult);  // 190 should be printed

			RtThread.sleepMs(2000);  // sleep for 2 sec	



		}


	}	

}