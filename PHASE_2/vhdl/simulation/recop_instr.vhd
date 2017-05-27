library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity recop_instr is
	port (opcode : in std_logic_vector(5 downto 0));
end recop_instr;

architecture sim of recop_instr is
	type op is (
	LDR,
	undefined_1,
	STR,
	SUBV,
	SUB,
	undefined_5,
	undefined_6,
	undefined_7,
	ANDr,
	undefined_9,
	undefined_10,
	undefined_11,
	ORr,
	undefined_13,
	undefined_14,
	undefined_15,
	CLFZ,
	undefined_17,
	undefined_18,
	undefined_19,
	SZ,
	undefined_21,
	undefined_22,
	undefined_23,
	JMP,
	undefined_25,
	undefined_26,
	undefined_27,
	PRESENT,
	STRPC,
	MAX,
	undefined_31,
	undefined_32,
	undefined_33,
	undefined_34,
	undefined_35,
	undefined_36,
	undefined_37,
	undefined_38,
	undefined_39,
	DCALLBL,
	DCALLNB,
	undefined_42,
	undefined_43,
	undefined_44,
	undefined_45,
	undefined_46,
	undefined_47,
	undefined_48,
	undefined_49,
	undefined_50,
	undefined_51,
	NOOP,
	undefined_53,
	LER,
	LSIP,
	ADD,
	undefined_57,
	SSOP,
	SSVOP,
	CER,
	undefined_61,
	CEOT,
	SEOT
);
signal val : op;
begin
	val <= op'val(to_integer(unsigned(opcode)));
end architecture;
