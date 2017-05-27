--
-- xv4ram_block.vhd
--
-- Generated by BlockGen
-- Wed Mar 19 15:37:17 NZDT 2014
--
-- This module will synthesize on Spartan3 and Virtex2/2Pro/2ProX devices.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.all;

entity xram_block is
	port (
		a_rst  : in std_logic;
		a_clk  : in std_logic;
		a_en   : in std_logic;
		a_wr   : in std_logic;
		a_addr : in std_logic_vector(7 downto 0);
		a_din  : in std_logic_vector(31 downto 0);
		a_dout : out std_logic_vector(31 downto 0);
		b_rst  : in std_logic;
		b_clk  : in std_logic;
		b_en   : in std_logic;
		b_wr   : in std_logic;
		b_addr : in std_logic_vector(7 downto 0);
		b_din  : in std_logic_vector(31 downto 0);
		b_dout : out std_logic_vector(31 downto 0)
	);
end xram_block;

architecture rtl of xram_block is

	component RAMB16_S36_S36
		port (
			DIA    : in std_logic_vector (31 downto 0);
			DIB    : in std_logic_vector (31 downto 0);
			ENA    : in std_logic;
			ENB    : in std_logic;
			WEA    : in std_logic;
			WEB    : in std_logic;
			SSRA   : in std_logic;
			SSRB   : in std_logic;
			DIPA   : in std_logic_vector (3 downto 0);
			DIPB   : in std_logic_vector (3 downto 0);
			DOPA   : out std_logic_vector (3 downto 0);
			DOPB   : out std_logic_vector (3 downto 0);
			CLKA   : in std_logic;
			CLKB   : in std_logic;
			ADDRA  : in std_logic_vector (8 downto 0);
			ADDRB  : in std_logic_vector (8 downto 0);
			DOA    : out std_logic_vector (31 downto 0);
			DOB    : out std_logic_vector (31 downto 0)
		); 
	end component;

	attribute INIT: string;
	attribute INIT_00: string;
	attribute INIT_01: string;
	attribute INIT_02: string;
	attribute INIT_03: string;
	attribute INIT_04: string;
	attribute INIT_05: string;
	attribute INIT_06: string;
	attribute INIT_07: string;
	attribute INIT_08: string;
	attribute INIT_09: string;
	attribute INIT_0a: string;
	attribute INIT_0b: string;
	attribute INIT_0c: string;
	attribute INIT_0d: string;
	attribute INIT_0e: string;
	attribute INIT_0f: string;
	attribute INIT_10: string;
	attribute INIT_11: string;
	attribute INIT_12: string;
	attribute INIT_13: string;
	attribute INIT_14: string;
	attribute INIT_15: string;
	attribute INIT_16: string;
	attribute INIT_17: string;
	attribute INIT_18: string;
	attribute INIT_19: string;
	attribute INIT_1a: string;
	attribute INIT_1b: string;
	attribute INIT_1c: string;
	attribute INIT_1d: string;
	attribute INIT_1e: string;
	attribute INIT_1f: string;
	attribute INIT_20: string;
	attribute INIT_21: string;
	attribute INIT_22: string;
	attribute INIT_23: string;
	attribute INIT_24: string;
	attribute INIT_25: string;
	attribute INIT_26: string;
	attribute INIT_27: string;
	attribute INIT_28: string;
	attribute INIT_29: string;
	attribute INIT_2a: string;
	attribute INIT_2b: string;
	attribute INIT_2c: string;
	attribute INIT_2d: string;
	attribute INIT_2e: string;
	attribute INIT_2f: string;
	attribute INIT_30: string;
	attribute INIT_31: string;
	attribute INIT_32: string;
	attribute INIT_33: string;
	attribute INIT_34: string;
	attribute INIT_35: string;
	attribute INIT_36: string;
	attribute INIT_37: string;
	attribute INIT_38: string;
	attribute INIT_39: string;
	attribute INIT_3a: string;
	attribute INIT_3b: string;
	attribute INIT_3c: string;
	attribute INIT_3d: string;
	attribute INIT_3e: string;
	attribute INIT_3f: string;

	attribute INIT_00 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_01 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_02 of cmp_ram_0: label is "1234567800000000000000000000000000000000000000000000000000000000";
	attribute INIT_03 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_04 of cmp_ram_0: label is "ffffff9100000002ffffff900000000400000000ffffff87ffffff8600000040";
	attribute INIT_05 of cmp_ram_0: label is "0000001fffffff84000000050000000300000006000000ff0000000100000008";
	attribute INIT_06 of cmp_ram_0: label is "12345678000000200000003f80000000ffffff85ffffff800000ffffffffffff";
	attribute INIT_07 of cmp_ram_0: label is "000000000132db1b123456781234567812345678123456781234567812345678";
	attribute INIT_08 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_09 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_0a of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_0b of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_0c of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_0d of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_0e of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_0f of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_10 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_11 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_12 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_13 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_14 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_15 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_16 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_17 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_18 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_19 of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_1a of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_1b of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_1c of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_1d of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_1e of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_1f of cmp_ram_0: label is "1234567812345678123456781234567812345678123456781234567812345678";
	attribute INIT_20 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_21 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_22 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_23 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_24 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_25 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_26 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_27 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_28 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_29 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_2a of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_2b of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_2c of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_2d of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_2e of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_2f of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_30 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_31 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_32 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_33 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_34 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_35 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_36 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_37 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_38 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_39 of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_3a of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_3b of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_3c of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_3d of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_3e of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";
	attribute INIT_3f of cmp_ram_0: label is "0000000000000000000000000000000000000000000000000000000000000000";

	signal p_a_addr : std_logic_vector (8 downto 0);
	signal p_b_addr : std_logic_vector (8 downto 0);

begin

	p_a_addr <= "0" & a_addr;
	p_b_addr <= "0" & b_addr;

	cmp_ram_0 : RAMB16_S36_S36
		port map (
			WEA => a_wr,
			WEB => b_wr,
			ENA => a_en,
			ENB => b_en,
			SSRA => a_rst,
			SSRB => b_rst,
			DIPA => "0000",
			DIPB => "0000",
			DOPA => open,
			DOPB => open,
			CLKA => a_clk,
			CLKB => b_clk,
			DIA => a_din(31 downto 0),
			ADDRA => p_a_addr,
			DOA => a_dout(31 downto 0),
			DIB => b_din(31 downto 0),
			ADDRB => p_b_addr,
			DOB => b_dout(31 downto 0)
		);

end rtl;
