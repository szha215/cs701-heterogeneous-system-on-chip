# ASP FSM State Transition Table

| Current State |               Input               |  Next State   | Output |
| :-----------: | :-------------------------------: | :-----------: | :----: |
|    `IDLE`     | `valid = 1`  and `opcode = 0000`  | `STORE_RESET` |        |
|               |  `valid = 1` and `opcode = 0001`  | `STORE_INIT`  |        |
|               |  `valid = 1` and `opcode = 0010`  |   `XOR_0_A`   |        |
|               |  `valid = 1` and `opcode = 0011`  |   `XOR_0_B`   |        |
|               |  `valid = 1` and `opcode = 0100`  |    `MAC_0`    |        |
|               |  `valid = 1` and `opcode = 0101`  |   `AVE_0_A`   |        |
|               |  `valid = 1` and `opcode = 0110`  |   `MAC_0_B`   |        |
|               | `valid = 1` and `opcode = others` |    `IDLE`     |        |
| `STORE_RESET` |                n/a                |  `SEND_ACC`   |        |
| `STORE_INIT`  |                n/a                | `STORE_WAIT`  |        |
| `STORE_WAIT`  |            `valid = 1`            | `SOTRE_DATA`  |        |
|               |            `valid = 0`            | `SOTRE_WAIT`  |        |
| `STORE_DATA`  |          `cmp_store = 1`          |  `SEND_ACC`   |        |
|               |          `cmp_store = 0`          | `SOTRE_WAIT`  |        |
|   `XOR_0_A`   |                n/a                |    `XOR_1`    |        |
|   `XOR_0_B`   |                n/a                |    `XOR_1`    |        |
|    `XOR_1`    |                n/a                |    `XOR_2`    |        |
|    `XOR_2`    |     `cmp_rd_pointer_end = 1`      |    `XOR_3`    |        |
|               |     `cmp_rd_pointer_end = 0`      |    `XOR_2`    |        |
|    `XOR_3`    |                n/a                |  `SEND_DATA`  |        |
|    `MAC_0`    |                n/a                |    `MAC_1`    |        |
|    `MAC_1`    |                n/a                |    `MAC_2`    |        |
|    `MAC_2`    |     `cmp_rd_pointer_end = 1`      |    `MAC_3`    |        |
|               |     `cmp_rd_pointer_end = 0`      |    `MAC_2`    |        |
|    `MAC_3`    |                n/a                |  `SEND_DATA`  |        |
|   `AVE_0_A`   |                n/a                |    `AVE_1`    |        |
|   `AVE_0_B`   |                n/a                |    `AVE_1`    |        |
|    `AVE_1`    |                n/a                |    `AVE_2`    |        |
|    `AVE_2`    |       `cmp_pointer_L = '1'`       |    `AVE_3`    |        |
|               |       `cmp_pointer_L = '0'`       |    `AVE_2`    |        |
|  `SEND_ACC`   |                n/a                |    `IDLE`     |        |
|  `SEND_DATA`  |          `cmp_sent = 1`           |    `IDLE`     |        |
|               |          `cmp_sent = 0`           | `SEND_PAUSE`  |        |
| `SEND_PAUSE`  |                n/a                |  `SEND_DATA`  |        |


