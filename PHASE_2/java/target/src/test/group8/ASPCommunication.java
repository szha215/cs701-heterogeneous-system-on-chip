package group8;

import java.util.*;
import java.io.*;
import com.jopdesign.sys.Const;
import com.jopdesign.sys.Native;
import joprt.RtThread;


public class ASPCommunication {

	public static void sendPacket(int packet){
		System.out.println("Sending Packet: " + Integer.toBinaryString(packet));
		Native.setDatacallResult(packet);
	}

	public static int pollASPResponse(){
		int datacallWord = 0;
		System.out.println("Started Polling response");

		while(true){
			datacallWord = Native.getDatacall();

			if ((datacallWord & (1 << 31)) != 0 && (datacallWord & (1 << 30)) != 0) {  // Valid and Legacy
				return datacallWord;
			}
		}
	}

	public static int storeReset(int memSel){

		// STORE reset command
		int packet = 0 | (0x3 << 30) | (memSel & 1 << 17);

		sendPacket(packet);

		return pollASPResponse();
	}

	public static int store(int[] data, int start, int memSel){

		// STORE command
		int packet = 0 | (0x3 << 30) | (1 << 22) | ((memSel & 1) << 17) | (data.length << 0);

		sendPacket(packet);

		for (int i = 0; i < data.length; i++){
			packet = 0 | (0x3 << 30) | ((i + start) << 16) | (data[i] << 0);

			sendPacket(packet);
		}

		return pollASPResponse();
	}

	public static int xor(int memSel, int start, int end){

		// XOR command
		int packet = 0 | (0x3 << 30) | ((2 + memSel) << 22) | (end << 9) | (start << 0);

		sendPacket(packet);

		return pollASPResponse();
	}

	public static long mac(int start, int end){
		long macResult = 0L;

		// MAC command
		int packet = 0 | (0x3 << 30) | (0x4 << 22) | (end << 9) | (start << 0);

		sendPacket(packet);

		for (int i = 0; i < 3; i++) {
			macResult = macResult | ((pollASPResponse() & 0xFFFF) << (i * 16));
		}

		return macResult;
	}

	public static int ave(int windowSize, int memSel){

		// AVE command
		int packet = 0 | (0x3 << 30) | ((5 + memSel) << 22) | (windowSize << 9);

		sendPacket(packet);

		return pollASPResponse();
	}
}