# ASP State Transition Table

***Note: `P` stands for pipeline***

| Current State |                Input                 |  Next State   | Output |
| :-----------: | :----------------------------------: | :-----------: | :----: |
|    `IDLE`     | `valid = '1'`  and `opcode = "0000"` | `STORE_RESET` |        |
|               | `valid = '1'` and `opcode = "0001"`  | `STORE_INIT`  |        |
|               | `valid = '1'` and `opcode = "0010"`  | `XOR_A_INIT`  |        |
|               | `valid = '1'` and `opcode = "0011"`  | `XOR_B_INIT`  |        |
|               | `valid = '1'` and `opcode = "0100"`  |  `MAC_INIT`   |        |
|               | `valid = '1'` and `opcode = "0101"`  | `AVE_A_INIT`  |        |
|               | `valid = '1'` and `opcode = "0110"`  | `AVE_B_INIT`  |        |
|               | `valid = '1'` and `opcode = others`  |    `IDLE`     |        |
| `STORE_RESET` |                 n/a                  |  `SEND_ACC`   |        |
| `STORE_INIT`  |                 n/a                  | `STORE_WAIT`  |        |
| `STORE_WAIT`  |            `valid = '1'`             | `SOTRE_DATA`  |        |
|               |            `valid = '0'`             | `SOTRE_WAIT`  |        |
| `STORE_DATA`  |          `cmp_store = '1'`           |  `SEND_ACC`   |        |
|               |          `cmp_store = '0'`           | `SOTRE_WAIT`  |        |
| `XOR_A_INIT`  |                 n/a                  | `XOR_P_START` |        |
| `XOR_B_INIT`  |                 n/a                  | `XOR_P_START` |        |
| `XOR_P_START` |                 n/a                  |    `XOR_P`    |        |
|    `XOR_P`    |      `cmp_rd_pointer_end = '1'`      |   `XOR_RES`   |        |
|               |      `cmp_rd_pointer_end = '0'`      |    `XOR_P`    |        |
|   `XOR_RES`   |                 n/a                  |  `SEND_DATA`  |        |
|  `MAC_INIT`   |                 n/a                  | `MAC_P_START` |        |
| `MAC_P_START` |                 n/a                  |    `MAC_P`    |        |
|    `MAC_P`    |      `cmp_rd_pointer_end = '1'`      |   `MAC_RES`   |        |
|               |      `cmp_rd_pointer_end = '0'`      |    `MAC_P`    |        |
|   `MAC_RES`   |                 n/a                  |  `SEND_DATA`  |        |
| `AVE_A_INIT`  |                 n/a                  | `AVE_P_START` |        |
| `AVE_B_INIT`  |                 n/a                  | `AVE_P_START` |        |
| `AVE_P_START` |                 n/a                  | `AVE_P_READ`  |        |
| `AVE_P_READ`  |        `cmp_pointer_L = '1'`         | `AVE_P_WRITE` |        |
|               |        `cmp_pointer_L = '0'`         | `AVE_P_READ`  |        |
|  `SEND_ACC`   |                 n/a                  |    `IDLE`     |        |
|  `SEND_DATA`  |           `cmp_sent = '1'`           |    `IDLE`     |        |
|               |           `cmp_sent = '0'`           | `SEND_PAUSE`  |        |
| `SEND_PAUSE`  |                 n/a                  |  `SEND_DATA`  |        |


