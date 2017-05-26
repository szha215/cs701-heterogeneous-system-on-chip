# Network Interface Simulation

The testbench `jni_ani_test.vhd` connects RNI, JNI, ANI, TDMA-MIN and ASP together to test the functionality of the modified JNI and our ANI by mocking ReCOP datacalls and JOP data calls. Details on the modification of JNI can be found in `jni_changes` readme file.





## Simulation Result

***1. The table below follows the full code provided in this document, table below shows the effect of `JMP` and `PRESENT` as well. (Tested with `SZ` instruction replacing `JMP` and `PRESENT` instructions as well)***

|       Code       |   Time Duration   | Mem\Reg\Port |
| :--------------: | :---------------: | :----------: |
|      `NOOP`      |   $0ns - 160ns$   |     n/a      |
|  `LDR R1 #123`   |  $160ns - 400ns$  | `R1 <= 007B` |
| `AND R2 R1 #111` |  $400ns - 640ns$  | `R2 <= 006B` |
|   `LDR R3 R2`    |  $640ns - 840ns$  | `R3 <= FFFF` |
|   `LDR R4 $2`    | $840ns - 1120ns$  | `R4 <= 007B` |
| `SUBV R4 R1 #23` | $1120ns - 1360ns$ | `R4 <= 0064` |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |
|                  |                   |              |

