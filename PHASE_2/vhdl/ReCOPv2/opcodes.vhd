library ieee;
use ieee.std_logic_1164.all;
use work.recop_types.all;

package opcodes is

-- instruction format
-- ---------------------------------------------
-- |AM(2)|OP(6)|Rz(4)|Rx(4)|ADDR/VAL/OTHERs(16)|
-- ---------------------------------------------


-- addressing modes (AM)
	constant am_inherent: bit_2 := "00"; 
	constant am_immediate: bit_2 := "01"; 
	constant am_direct: bit_2 := "10";
	constant am_register: bit_2 := "11";

-----------------------------	
--   normal instructions   --
-----------------------------

-- operations with immediate, direct and indirect AM
	-- immediate: LDR Rz #value
	-- indirect: LDR Rz $address
	-- direct: LDR Rz Rx
	constant ldr: bit_6 := "000000";

	
-- operations with direct and immediate AM
	-- immediate: STR Rz #value
	-- indirect: STR Rz Rx
	-- direct: STR Rx Op
	constant str: bit_6 := "000010";
 

-- operations with immediate and direct AM
	-- immediate: JMP #address 
   -- direct: JMP Rx 
	constant jmp: bit_6 := "011000";
	
-- operations with direct AM
   -- direct: PRESENT Rz Rx 
	constant present: bit_6 := "011100";

-- operations with immediate and direct AM
	constant andr: bit_6 := "001000"; --  AND Rz Rx Op
	constant orr : bit_6 := "001100"; --  OR Rz Rx Op
	constant addr: bit_6 := "111000"; --  ADD Rz Rx Op
	constant subr: bit_6  := "000100"; --  SUB Rz Op
	constant subvr: bit_6 := "000011"; -- SUBV RZ Rx Op
	constant lslr: bit_6 := "001110"; --  LSL Rz Rx
	constant lsrr: bit_6 := "001101"; --  LSR Rz Rx
	constant notr: bit_6 := "001111"; --  NOT Rz Rx

-- operations with inherent AM
   constant clfz: bit_6 := "010000";
   constant cer : bit_6 := "111100";
   constant ceot: bit_6 := "111110";
   constant seot: bit_6 := "111111";
   constant noop: bit_6 := "110100";
   
-- operations with immediate AM
   -- SZ Op
   constant  sz : bit_6 := "010100";

-- operations with direct AM
   -- LER Rz
   constant  ler : bit_6 := "110110";

----------------------------	
--  special instructions  --
----------------------------
	
-- operations with direct AM
   -- direct: SSVOP Rx 
	constant ssvop: bit_6 := "111011";
	
-- operations with direct AM
   -- direct: SSOP Rx 
	constant ssop: bit_6 := "111010";
	
-- operations with direct AM
   -- direct: LSIP Rx 
	constant lsip: bit_6 := "110111";

---------------------------
--  other instructions  --
---------------------------
-- operations with register and immediate AM
	-- register: DATACALL Rx
	-- immediate : DATACALL Rx #value
	constant datacall: bit_6 := "101000";
	constant dcallbl: bit_6 := "101000";
	constant dcallnb: bit_6 := "101001";
	constant iocall:  bit_6 := "101011";
	
-- operations with immediate AM
	-- immediate : MAX Rz #value
	constant max: bit_6 := "011110";
	
-- operations with direct AM
	-- direct : STRPC Rz $address
	constant strpc: bit_6 := "011101";

-- operation with register AM
	-- register : SRES Rz
	constant sres: bit_6 := "101010";
	
end opcodes;
