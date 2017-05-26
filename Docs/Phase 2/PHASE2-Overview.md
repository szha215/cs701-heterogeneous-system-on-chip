# PHASE TWO Group 8 Overview

## Implementation Overview

### Program development for JOP
As with in Lab 3, the JOPs were programmed into the DE2-115 board. There are three JOPs that are programmed with our Matrix Product function. Refer to `multi_jop_program` documentation for further details.

### Adaptation of JOP Network Interface (JNI) to support communication with ASP

JNI has gone through some modifications inorder to support the communication with the ASP and the ANI interfacing. Refer to `JNI Changes` documentation for further details.

### Integration of JOP and ASP using TDMA-MIN

To enable the interfacing of the JOP to the ASP, the ASP interface is added into the NoC. A block is created that is a composition of ANI and ASP together as the `asp_ani_combined` component. In the NoC a loop generate is used to create the number of specified ASPs and corresponding ANIs together. 

In the test bench, the DataCall, there exists `XXX` signals for some of the ports. These are indicate that the port are not connected to the NoC.

### Integration of ReCOP and JOP using TDMA-MIN