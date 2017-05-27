package group8;

import com.jopdesign.sys.*;
import util.*;

public class SevenSeg {

	public static void main(String[] args) {
		
		int switches, bcd;
		int val = 0;

		while(true){
			// Wait 5 sek
			Timer.wd();
			int i = Timer.getTimeoutMs(500);
			while (!Timer.timeout(i));
			
			val+=2;
			switches = Native.rdMem(Const.LS_BASE);
			if (switches % 2 == 1){
				if (val % 2 == 1)
					val--;
			}
			else{
				if (val % 2 == 0)
					val --;
			}
			val = val % 100;
			bcd = int2bcd(val);
			
			
			Native.wrMem(bcd,Const.SS_BASE);
			Native.wrMem(bcd,Const.LS_BASE);
		}
	}

	public static void writeToSevenSegDec(int num){
		Native.wrMem(int2bcd(num),Const.SS_BASE);
	}

	public static void writeToSevenSegHex(int num){
		Native.wrMem(num,Const.SS_BASE);
	}

	public static void writeToLED(int num){
		Native.wrMem(int2bcd(num),Const.LS_BASE);
	}

	private static int int2bcd(int val){
		int[] digits = new int[4];
		int reminder, bcd = 0;
		
		reminder = val % 10000;
		digits[3] = reminder / 1000;
		reminder = reminder % 1000;
		digits[2] = reminder / 100;
		reminder = reminder % 100;
		digits[1] = reminder / 10;
		reminder = reminder % 10;
		digits[0] = reminder;
		
		bcd = 4096*digits[3]+256*digits[2]+16*digits[1]+digits[0];
		return bcd;
	}
}
