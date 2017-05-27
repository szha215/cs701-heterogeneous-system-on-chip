/**
 * Created by seanwu on 25/05/17.
 */

package test;

public class PacketConstructor {
    private int printType = 0;
    private int opcode = 0;
    private int destPort = 0;
    private int sourcePort = 0;
    private int memSel = 0;
    private int numWords = 0;
    private int endAddr = 0;
    private int beginAddr = 0;
    private int lastBit = 0;
    private int addr = 0;
    private int data = 0;

    private int packet = 0;

 

    public PacketConstructor(OPCODE.OP op, int destPort, int sourcePort, int arg2, int arg3){
        parsePacketArgs(op,destPort,sourcePort,arg2,arg3);
        buildPacket(opcode);
    }

    public PacketConstructor(int destPort, int lastBit, int addr, int data){
        parsePacketArgs(destPort,lastBit,addr,data);

        buildDataPacket();
    }

    private void parsePacketArgs(int destPort, int lastBit, int addr, int data){
        this.destPort = destPort;
        this.lastBit = lastBit;
        this.addr = addr;
        this.data = data;
    }

    private void parsePacketArgs(OPCODE.OP op, int destPort, int sourcePort, int arg2, int arg3){
        //arg2 and arg3 can be either memSel and numWords or endAddr and beginAddr depends on opcode

        if(op == OPCODE.OP.STORE0){
            this.opcode = 0x0;
        }else if(op == OPCODE.OP.STORE1){
            this.opcode = 0x1;
        }else if(op == OPCODE.OP.XORA){
            this.opcode = 0x2;
        }else if(op == OPCODE.OP.XORB){

            this.opcode = 0x3;
        }else if(op == OPCODE.OP.MAC){
            this.opcode = 0x4;
        }else if(op == OPCODE.OP.AVEA){
            this.opcode = 0x5;
        }else if(op == OPCODE.OP.AVEB){
            this.opcode = 0x6;
        }


        this.destPort = destPort;
        this.sourcePort = sourcePort;
        //For store cmds
        this.memSel = arg2;
        this.numWords = arg3;
        //For other cmds
        this.endAddr = arg2;
        this.beginAddr = arg3;
    }

    public void updatePacket(OPCODE.OP op, int destPort, int sourcePort, int arg2, int arg3){
        parsePacketArgs(op,destPort,sourcePort,arg2,arg3);
        buildPacket(opcode);
    }

    public void updatePacket(int destPort, int lastBit, int addr, int data){
        parsePacketArgs(destPort,lastBit,addr,data);
        buildDataPacket();
    }

    public void buildPacket(int opcode){
        if((opcode == 0x0) | (opcode == 0x1)) {
            printType = 0;
            packet = (0x3 << 30) | (destPort << 26) | (opcode << 22) | (sourcePort << 18) | (memSel << 17) | (0x0 << 9) | (numWords << 0) & 0xFFFFFFFF;
        }else{
            printType = 1;

            packet = (0x3 << 30) | (destPort << 26) | (opcode << 22) | (sourcePort << 18) | (endAddr << 9) | (beginAddr << 0) & 0xFFFFFFFF;
        }
    }

    public void buildDataPacket(){
        printType = 2;

        packet = (0x3 << 30) | (destPort << 26) | (lastBit << 25) | (addr << 16) | (data << 0) & 0xFFFFFFFF;
    }

    public int getPacket(){
        return packet;
    }

    public void printPacket(){

        System.out.println("\n" + Integer.toBinaryString(packet));
        String temp = Integer.toBinaryString(packet);
        if(printType == 0){
            System.out.println("Dest Port: " + temp.substring(2,6));
            System.out.println("Source Port: " + temp.substring(10,14));
            System.out.println("OP code: " + temp.substring(6,10));
            System.out.println("memsel: " + temp.substring(14,15));
            System.out.println("Number of words: " + temp.substring(23,32));

        }else if(printType == 1){
            System.out.println("Dest Port: " + temp.substring(2,6));
            System.out.println("Source Port: " + temp.substring(10,14));
            System.out.println("OP code: " + temp.substring(6,10));
            System.out.println("Begin Addr: " + temp.substring(23,32));
            System.out.println("End Addr: " + temp.substring(14,23));

        }else if(printType == 2){
            System.out.println("Dest Port: " + temp.substring(2,6));
            System.out.println("Last Bit: " + temp.substring(6,7));
            System.out.println("Address: " + temp.substring(7,16));
            System.out.println("Data: " + temp.substring(16,32));

        }

    }

    public static void main(String args[]){
        PacketConstructor store0pkt = new PacketConstructor(OPCODE.OP.STORE0,0x0,0x1,0x0,0x0);
        store0pkt.printPacket();


        store0pkt.updatePacket(OPCODE.OP.STORE1,0x1,0x2,0x1,0x3);
        store0pkt.printPacket();


        PacketConstructor store1pkt = new PacketConstructor(OPCODE.OP.STORE1,0x1,0x2,0x1,0x3);
        store1pkt.printPacket();

        PacketConstructor xorApkt = new PacketConstructor(OPCODE.OP.XORA,0x3,0x4,0x5,0x4);
        xorApkt.printPacket();

        PacketConstructor xorBpkt = new PacketConstructor(OPCODE.OP.XORB,0x5,0x6,0x10,0x9);
        xorBpkt.printPacket();

        PacketConstructor macPkt = new PacketConstructor(OPCODE.OP.MAC,0x7,0x8,0x20,0x15);
        macPkt.printPacket();

        PacketConstructor aveApkt = new PacketConstructor(OPCODE.OP.AVEA,0x9,0x10,0x30,0x25);
        aveApkt.printPacket();

        PacketConstructor aveBpkt = new PacketConstructor(OPCODE.OP.AVEB,0x11,0x12,0x40,0x35);
        aveBpkt.printPacket();

        PacketConstructor dataPkt = new PacketConstructor(0x22,0x1,0x100,0x12);
        dataPkt.printPacket();

        dataPkt.updatePacket(0x1,0x1,0x1,0x1);
        dataPkt.printPacket();


    }


}
