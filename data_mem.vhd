library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library lpm;
--use lpm.lpm_components.all;
library altera_mf;
use altera_mf.all;

library work;
use work.all;


entity data_mem is
generic(
	constant ram_addr_width : positive := 16;
	constant ram_data_width : positive := 16
);

port (
	clk 		:	in std_logic;
	wr_en		:	in std_logic;
	addr		:	in std_logic_vector(ram_addr_width - 1 downto 0);
	data_in	:	in std_logic_vector(ram_data_width - 1 downto 0);
	data_out	:	out std_logic_vector(ram_data_width - 1 downto 0)		
) ;
end entity ; -- data_mem

architecture behaviour of data_mem is

	COMPONENT altsyncram
	GENERIC (
		clock_enable_input_a		: STRING;
		clock_enable_output_a		: STRING;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_type		: STRING;
		numwords_a		: NATURAL;
		operation_mode		: STRING;
		outdata_aclr_a		: STRING;
		outdata_reg_a		: STRING;
		power_up_uninitialized		: STRING;
		ram_block_type		: STRING;
		widthad_a		: NATURAL;
		width_a		: NATURAL;
		width_byteena_a		: NATURAL
	);
	PORT (
			address_a	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			clock0	: IN STD_LOGIC ;
			data_a	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren_a	: IN STD_LOGIC ;
			q_a	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	END COMPONENT;



begin

--ram: lpm_ram_dq
--	generic map(
--		lpm_widthad => ram_addr_width,
--		lpm_width	=>	ram_data_width,
--		lpm_indata	=>	"UNREGISTERED",
--		lpm_outdata => "UNREGISTERED",
--		lpm_address_control => "UNREGISTERED",
--		lpm_file 	=> "data_ram.hex"
--		)
--	port map(
--		data 		=> data_in,
--		address 	=> addr,
--		we 		=> wr_en,
--		q 			=> data_out
--	);

	altsyncram_component : altsyncram
	GENERIC MAP (
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 4096,
		operation_mode => "SINGLE_PORT",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		ram_block_type => "M4K",
		widthad_a => 12,
		width_a => 16,
		width_byteena_a => 1
	)
	PORT MAP (
		address_a => addr(11 downto 0),
		clock0 => clk,
		data_a => data_in,
		wren_a => wr_en,
		q_a => data_out
	);






end architecture;