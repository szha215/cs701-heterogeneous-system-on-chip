/**
 * Created by seanwu on 25/05/17.
 */
package group8;

public class PacketDecoder {


    private int packet = 0;
    private int valid = 0;
    private int destPort = 0;
    private int opcode = 0;
    private int sourcePort = 0;
    private int result = 0;
    private int id = 0;
    public PacketDecoder(int packet){
        this.packet = packet;
        decodePacket(packet);
    }

    public void decodePacket(int packet){
        valid = (packet >> 31) & 0x1;
        destPort = (packet >> 26) & 0xF;
        opcode = (packet >> 22) & 0xF;
        sourcePort = (packet >> 18) & 0xF;
        id = (packet >> 16) & 0x3;
        result = (packet >> 0) & 0xFFFF;
    }

    public int getValid(){
        return valid;
    }

    public int getDestPort(){
        return destPort;
    }

    public int getOpCode(){
        return opcode;
    }

    public int getResult(){
        return result;
    }

    public int getID(){
        return id;
    }

    public void printResult(){
        System.out.println("\nValid: " + Integer.toBinaryString(valid));
        System.out.println("Dest Port: " + Integer.toBinaryString(destPort));
        System.out.println("Source Port: " + Integer.toBinaryString(sourcePort));
        System.out.println("OP code: " + Integer.toBinaryString(opcode));
        System.out.println("ID: " + Integer.toBinaryString(id));
        System.out.println("Result: " + Integer.toBinaryString(result));
    }

    public static void main(String args[]){
        PacketConstructor aveApkt = new PacketConstructor(OPCODE.OP.AVEA,0x9,0x4,0x0,0x25);
        aveApkt.printPacket();

        
        PacketDecoder pktDec = new PacketDecoder(aveApkt.getPacket());
        pktDec.printResult();
        SevenSeg.writeToSevenSeg(pktDec.getResult());
    }



}
