# ReCOP and ASP Integration with JOP

***Note: Refer to `PacketSender.java` for more implementation details***

## ReCOP to JOP

ReCOP will send datacall packets to JOP and wait for replies from JOP. Refer to **Assembly Program used for ReCOP** section for more details.

Initially ReCOP will send a Packet of `0xAAA` and poll for the reply from JOP. Consecutively, ReCOP will send packets `0xBBB` and `0xCCC` for more instructions to JOP acting as "pseudo-opcodes".

## JOP to ASP

After receiving a packet from ReCOP, JOP will proceed to send commands to ASP.

A simple case switch is implemented for parsing those packets.

### `0xAAA`

1. JOP will first send a `store` command to ASP storing an array to vector `B` : ` arrayB = {0x0, 0x99, 0x101, 0x103, 0x105, 0x107, 0x109, 0x0}` to addresses from `0` to `7`.
2. Then if ASP sends an access granted packet back to JOP, JOP will proceed to print the result to seven seg display and sleep for 2 seconds.
3. After this, JOP will send a `xor` command to ASP to perform on vector `B` from addresses `0` to `7`. Expected result is `0x190` and it will be printed both in console and on seven seg display and sleep for 2 secs.
4. JOP will now send a reply back to ReCOP in order to receive the next packet `0xBBB`

### `0xBBB`

1. JOP will first send a `average` command to ASP to average vector `B` with a window size `L = 4`.
2. Then JOP will send a `store` command to ASP to store an array to vector `A` with array: `arrayA = {0xECE, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777}` to address from addresses `0` to `7`. 
3. Then JOP will send a `mac` command to ASP to perform an `mac` operation from addresses `0` to `511`. The expected result is `0x190` and it will be printed to both terminal and seven seg display.
   1. Since ASP that we implemented will send 3 packets to JOP, this program will also handle the concatenation of those 3 packets and produce a `long` number. 

### `0xCCC`

1. JOP will perform the identical matrix multiplication computation described in `multi_jop_program` document. This is to demonstrate multi-jop communication and computation. 

## Assembly program used for ReCOP

```assembly
start NOOP
  ADD R1 R1 #2730
  DCALLBL R1 #32768

POLL_DPRR NOOP
  LDR R0 $0
  SUBV R3 R0 #3
  PRESENT R3 REPLY
  JMP POLL_DPRR

REPLY NOOP
  LDR R2 #0
  ADD R1 R2 #3003
  DCALLBL R1 #32768

NOOP_LOOP NOOP
  NOOP
  JMP NOOP_LOOP

ENDPROG 
```

