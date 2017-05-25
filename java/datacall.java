package test_datacall;
import java.util.*;
import java.io.*;
import com.jopdesign.sys.Const;
import com.jopdesign.sys.Native;
import joprt.RtThread;
public class datacall{
	private static boolean retval = false;
	private static int dl = 0;
	private static Vector currsigs0 = new Vector();
	
	public static void main(String args[]){
		System.out.println("starting main!");
		long data_call_word=0;
		while(true){
			data_call_word=Native.getDatacall();
			if (data_call_word != 0){
				
				System.out.println(data_call_word);
				Native.setDatacallResult(0x80000003);
			}
			RtThread.sleepMs(300);
		}
	}
}