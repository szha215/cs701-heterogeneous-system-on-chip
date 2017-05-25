/**
 * Created by seanwu on 25/05/17.
 */
public class PacketDecoder {


    private int packet = 0;
    private int valid = 0;
    private int destPort = 0;
    private int opcode = 0;
    private int sourcePort = 0;
    private int result = 0;
    public PacketDecoder(int packet){
        this.packet = packet;
        decodePacket(packet);
    }

    public void decodePacket(int packet){
        valid = (packet >> 31) & 0b1;
        destPort = (packet >> 26) & 0xF;
        opcode = (packet >> 22) & 0xF;
        sourcePort = (packet >> 18) & 0xF;
        result = (packet >> 0) & 0xFFFF;
    }

    public void printResult(){
        System.out.println("\nValid: " + Integer.toBinaryString(valid));
        System.out.println("Dest Port: " + Integer.toBinaryString(destPort));
        System.out.println("Source Port: " + Integer.toBinaryString(sourcePort));
        System.out.println("OP code: " + Integer.toBinaryString(opcode));
        System.out.println("Result: " + Integer.toBinaryString(result));
    }

    public static void main(String args[]){
        PacketConstructor aveApkt = new PacketConstructor("AVEA",0x9,0x4,0x30,0x25);
        aveApkt.printPacket();

        PacketDecoder pktDec = new PacketDecoder(aveApkt.getPacket());
        pktDec.printResult();
    }



}
