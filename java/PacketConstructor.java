/**
 * Created by seanwu on 25/05/17.
 */
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
    public PacketConstructor(String opcodeStr, int destPort, int sourcePort, int arg2, int arg3){
        //arg2 and arg3 can be either memSel and numWords or endAddr and beginAddr depends on opcode
        switch (opcodeStr){
            case "STORE0":
                opcode = 0x0;
                break;
            case "STORE1":
                opcode = 0x1;
                break;
            case "XORA":
                opcode = 0x2;
                break;
            case "XORB":
                opcode = 0x3;
                break;
            case "MAC":
                opcode = 0x4;
                break;
            case "AVEA":
                opcode = 0x5;
                break;
            case "AVEB":
                opcode = 0x6;
                break;
        }

        this.destPort = destPort;
        this.sourcePort = sourcePort;
        //For store cmds
        this.memSel = arg2;
        this.numWords = arg3;
        //For other cmds
        this.endAddr = arg2;
        this.beginAddr = arg3;
        buildPacket(opcodeStr);
    }

    public PacketConstructor(int destPort, int lastBit, int addr, int data){

        this.destPort = destPort;
        this.lastBit = lastBit;
        this.addr = addr;
        this.data = data;
        buildDataPacket();
    }

    public void buildPacket(String opcodeStr){
        if((opcodeStr == "STORE1") || (opcodeStr == "STORE0")) {
            printType = 0;
            packet = (0x3 << 30) | (destPort << 26) | (opcode << 22) | (sourcePort << 18) | (memSel << 17) | (0x0 << 9) | (numWords << 0) & 0xFFFFFFFF;
        }else if((opcodeStr == "XORA") || (opcodeStr == "XORB") || (opcodeStr == "MAC") || (opcodeStr == "AVEA") ||(opcodeStr == "AVEB")){
            printType = 1;

            packet = (0x3 << 30) | (destPort << 26) | (opcode << 22) | (sourcePort << 18) | (endAddr << 9) | (beginAddr << 0) & 0xFFFFFFFF;
        }
    }

    public void buildDataPacket(){
        printType = 2;

        packet = (0x3 << 30) | (destPort << 26) | (lastBit << 25) | (addr << 15) | (data << 0) & 0xFFFFFFFF;
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
        PacketConstructor store0pkt = new PacketConstructor("STORE0",0x0,0x1,0x0,0x0);
        store0pkt.printPacket();

        PacketConstructor store1pkt = new PacketConstructor("STORE1",0x1,0x2,0x1,0x3);
        store1pkt.printPacket();

        PacketConstructor xorApkt = new PacketConstructor("XORA",0x3,0x4,0x5,0x4);
        xorApkt.printPacket();

        PacketConstructor xorBpkt = new PacketConstructor("XORB",0x5,0x6,0x10,0x9);
        xorBpkt.printPacket();

        PacketConstructor macPkt = new PacketConstructor("MAC",0x7,0x8,0x20,0x15);
        macPkt.printPacket();

        PacketConstructor aveApkt = new PacketConstructor("AVEA",0x9,0x10,0x30,0x25);
        aveApkt.printPacket();

        PacketConstructor aveBpkt = new PacketConstructor("AVEB",0x11,0x12,0x40,0x35);
        aveBpkt.printPacket();

        PacketConstructor dataPkt = new PacketConstructor(0x22,0x0,0x100,0x12);
        dataPkt.printPacket();


    }


}
