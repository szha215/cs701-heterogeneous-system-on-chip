# ASP State Transition Table

***Note: `P` stands for pipeline***

| Current State |                Input                 |  Next State   |                  Output                  |
| :-----------: | :----------------------------------: | :-----------: | :--------------------------------------: |
|    `IDLE`     | `valid = '1'`  and `opcode = "0000"` | `STORE_RESET` |               Reset things               |
|               | `valid = '1'` and `opcode = "0001"`  | `STORE_INIT`  |                    ''                    |
|               | `valid = '1'` and `opcode = "0010"`  | `XOR_A_INIT`  |                    ''                    |
|               | `valid = '1'` and `opcode = "0011"`  | `XOR_B_INIT`  |                    ''                    |
|               | `valid = '1'` and `opcode = "0100"`  |  `MAC_INIT`   |                    ''                    |
|               | `valid = '1'` and `opcode = "0101"`  | `AVE_A_INIT`  |                    ''                    |
|               | `valid = '1'` and `opcode = "0110"`  | `AVE_B_INIT`  |                    ''                    |
|               | `valid = '1'` and `opcode = others`  |    `IDLE`     |                    ''                    |
| `STORE_RESET` |                 n/a                  |  `SEND_ACC`   |              Reset vectors               |
| `STORE_INIT`  |                 n/a                  | `STORE_WAIT`  |           Load words to store            |
| `STORE_WAIT`  |            `valid = '1'`             | `SOTRE_DATA`  |                   n/a                    |
|               |            `valid = '0'`             | `SOTRE_WAIT`  |                    ''                    |
| `STORE_DATA`  |          `cmp_store = '1'`           |  `SEND_ACC`   |         Vector load enable, busy         |
|               |          `cmp_store = '0'`           | `SOTRE_WAIT`  |                    ''                    |
| `XOR_A_INIT`  |                 n/a                  | `XOR_P_START` |    Set mem_sel, clear pointers, busy     |
| `XOR_B_INIT`  |                 n/a                  | `XOR_P_START` |                    ''                    |
| `XOR_P_START` |                 n/a                  |    `XOR_P`    | Start incrementing rd_pointer, clear res |
|    `XOR_P`    |      `cmp_rd_pointer_end = '1'`      |   `XOR_RES`   |       keep incrementing rd_pointer       |
|               |      `cmp_rd_pointer_end = '0'`      |    `XOR_P`    |                    ''                    |
|   `XOR_RES`   |                 n/a                  |  `SEND_DATA`  | Stop incrementing rd_pointer, stop loading res |
|  `MAC_INIT`   |                 n/a                  | `MAC_P_START` |              Clear pointers              |
| `MAC_P_START` |                 n/a                  |    `MAC_P`    | Start incrementing rd_pointer, clear res |
|    `MAC_P`    |      `cmp_rd_pointer_end = '1'`      |   `MAC_RES`   |       Keep incrementing rd_pointer       |
|               |      `cmp_rd_pointer_end = '0'`      |    `MAC_P`    |                    ''                    |
|   `MAC_RES`   |                 n/a                  |  `SEND_DATA`  | Stop incrementing rd_pointer, stop loading res |
| `AVE_A_INIT`  |                 n/a                  | `AVE_P_START` |           Clear rd/wr pointers           |
| `AVE_B_INIT`  |                 n/a                  | `AVE_P_START` |                    ''                    |
| `AVE_P_START` |                 n/a                  | `AVE_P_READ`  | Clear AVE block, start incrementing rd_pointer |
| `AVE_P_READ`  |        `cmp_pointer_L = '1'`         | `AVE_P_WRITE` |       Keep incrementing rd_pointer       |
| `AVE_P_WRITE` |        `cpp_pointer_1` = '1'         |  `SEND_ACC`   |      Start incrementing wr_pointer       |
|               |        `cmp_pointer_L = '0'`         | `AVE_P_WRITE` |                    ''                    |
|  `SEND_ACC`   |                 n/a                  |    `IDLE`     |     Send ACC_GRANTED, set res_ready      |
|  `SEND_DATA`  |           `cmp_sent = '1'`           |    `IDLE`     | Send data packet mux'ed by packet ID, res_ready |
|               |           `cmp_sent = '0'`           | `SEND_PAUSE`  |                    ''                    |
| `SEND_PAUSE`  |                 n/a                  |  `SEND_DATA`  |             Clear res_ready              |


