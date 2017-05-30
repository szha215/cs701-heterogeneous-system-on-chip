# PHASE TWO Group 8 Overview

***Note: Refer to `docs` directory for additional  documents***

## Compiling the Project

Refer to the `README.md` file.

## Implementation Overview

### Program development for JOP

As with in Lab 3, the JOPs were programmed into the DE2-115 board. There are three JOPs that are programmed with our Matrix Product function. Refer to `multi_jop_program` documentation for further details.

### Adaptation of JOP Network Interface (JNI) to support communication with ASP

JNI has gone through some modifications in order to support the communication with the ASP and the ANI interfacing. Refer to `jni_changes` documentation for further details. Also refer to `rni_jni_ani_simulation` to find test bench results of network interfaces connected all together.

### Integration of JOP and ASP using TDMA-MIN

To enable the interfacing of the JOP to the ASP, the ASP interface is added into the NoC. A new block combining ANI and ASP is created as the `asp_ani_combined` component. In the NoC, a loop generate is used to create the number of specified ASPs and corresponding ANIs together. 

### Integration of ReCOP and JOP using TDMA-MIN

We integrated our own ReCOP into the TDMA-MIN, its current ASM code sends datacall packets to JOP and by using a specific Java program, JOP is able to respond accordingly. Specifically JOP will then proceed to send different commands to ASP. Refer to `recop_asp_jop_integration` document for more details. Our ReCOP follows the given ISA very closely, eg. `DCALLBL` will block, operand is the lower part.

## Changes since Phase One

The ReCOP has been modified from Von Neumann to Harvard architecture where by, the Program memory and Data memory are separate entities. Refer to `recop_datapath_harvard` for the new data path diagram.

ASP is modified to support resetting vectors.

## Future Implementation

In order to complete the ADD-HSoC, there needs to be the implementation of the SystemJ code.

ReCOP changes for data call concatenation order can easily be done if required



