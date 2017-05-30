# ReCOP and ASP Integration with JOP

***Note: Refer to `PacketSender.java` for more implementation details***

## ReCOP to JOP

ReCOP will send data call packets to JOP and wait for replies from JOP. Refer to **Assembly Program used for ReCOP** section for more details.

Initially ReCOP will send a data call packet of `1111`(`0x457`) and then `2222`(`0x8AE`) back to back, then it will poll for the reply from JOP. One response is sent after processing `2222`  and then ReCOP will send the packet `3333`(`0xD05`). These data calls act as instructions to JOP acting as "pseudo-opcodes".

The back to back sending is to show that the JOP does not process the second of the two ReCOP instructions when the first one has not yet been processed.

## ReCOP data calls

After receiving a packet from ReCOP, a simple case switch is implemented for parsing these packets.

### `1111` or `0x457`

1. JOP will perform the matrix multiplication computation described in `multi_jop_program` document. This is to demonstrate multi-JOP communication and computation. 

### `2222` or `0x8AE`

1. JOP will first send a `store` command to ASP storing an array to vector `B` with array: ` arrayB = {0x0, 0x99, 0x101, 0x103, 0x105, 0x107, 0x109, 0x0}` to addresses from `0` to `7`.
2. Then if ASP sends an access granted packet back to JOP, JOP will proceed to print the result to console and then seven seg display.
3. After, the JOP will send an `xor` command to ASP to perform on vector `B` from addresses `0` to `7`. Expected result is `0x190` and it will be printed both in console and on seven seg display.
4. JOP will now send a reply back to ReCOP.

### `3333` or `0xD05`

1. The JOP will send a `store` command to ASP to store an array to vector `A` with array: `arrayA = {0xECE, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777}` to addresses from `0` to `7`. 
2. Then JOP will send a `mac` command to ASP to perform a `mac` operation from addresses `0` to `511`. The expected result is `0x167721` and it will be printed to both terminal and seven seg display.
   1. Since the ASP that we implemented sends 3 packets to JOP, this program will also handle the concatenation of these 3 packets and produce a `long` type number. 
3. JOP will send an `ave` command to ASP to average vector `B` with a window size `L = 4`.
4. Then JOP will send a `mac` command to ASP again, however this time the expected result changes to `0x17BEF8`, as the averaging has now changed the vector `B` and consequently changed the result of the `mac` command.

## Assembly program used for ReCOP

```assembly
start NOOP
  LDR R1 #32768
  DCALLNB R1 #1111
  
  DCALLNB R1 #2222

POLL_DPRR NOOP
  LDR R0 $0
  SUBV R3 R0 #3
  PRESENT R3 REPLY
  JMP POLL_DPRR

REPLY NOOP
  DCALLNB R1 #3333

NOOP_LOOP NOOP
  NOOP
  JMP NOOP_LOOP

ENDPROG 
```

- `start` sends the two data calls
- `POLL_DPRR` polls for the write back address to be written with result and IRQ, then jumps to `REPLY` when reply is received
- `REPLY` sends another packet
- `NOOP_LOOP` will loop forever

Data Calls in our ReCOP is the right way around, where the valid, legacy and ID numbers are stored in register, and address information in operand or R7.

This can be 