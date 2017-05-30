# Network Interface Simulation

The testbench `jni_ani_test.vhd` connects RNI, JNI, ANI, TDMA-MIN and ASP together to test the functionality of the modified JNI and our ANI by mocking ReCOP datacalls and JOP data calls. Details on the modification of JNI can be found in `jni_changes` readme file.

## Simulation Result



|  Time   |               Description                |
| :-----: | :--------------------------------------: |
|  60 ns  | ReCOP sends AAA command (testbench controlled) |
| 140 ns  |         ReCOP sends BBB command          |
| 200 ns  |           RNI pops AAA to NoC            |
| 220 ns  |         ReCOP sends CCC command          |
| 240 ns  |           JOP ACK (testbench)            |
| 280 ns  | JOP sends an MAC invoke to JNI (testbench) |
| 320 ns  | DPCR is not popping BBB because of ASP Invoke |
| 440 ns  |        JNI pops ASP Invoke to NoC        |
| 540 ns  |            ASP busy goes high            |
| 860 ns  |       ANI pops first packet to NoC       |
| 880 ns  |     First packet (ID 0) going in JOP     |
| 1200 ns |     Last packet (ID 2) going in JOP      |
| 1280 ns |   JOP receives BBB (since ASP is done)   |
| 1360 ns |             JOP receives CCC             |
|         |                                          |

RNI, JNI and ANI works as expected.


