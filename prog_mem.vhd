library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library lpm;
--use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

library work;
use work.all;


entity prog_mem is
generic(
	constant ram_addr_width : positive := 16;
	constant ram_data_width : positive := 16;
	constant recop_id		: integer
);

port (
	clk 		:	in std_logic;
	addr		:	in std_logic_vector(ram_addr_width - 1 downto 0);


	data_out	:	out std_logic_vector(ram_data_width - 1 downto 0)		
) ;
end entity ; -- prog_mem

architecture behaviour of prog_mem is

component altsyncram
	generic (
		clock_enable_input_a : string;
		clock_enable_output_a : string;
		init_file : string;
		intended_device_family : string;
		lpm_hint : string;
		lpm_type : string;
		maximum_depth : natural;
		numwords_a : natural;
		operation_mode  : string;
		outdata_aclr_a  : string;
		outdata_reg_a  : string;
		ram_block_type  : string;
		widthad_a  : natural;
		width_a  : natural;
		width_byteena_a  : natural

	);
	port (
			address_a	: in std_logic_vector (ram_addr_width - 1  downto 0);
			clock0	: in std_logic ;
			q_a	: out std_logic_vector (ram_data_width - 1 downto 0)
			
	);
	end component;



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

--ram_a : altsyncram
--	generic map (
		
--		init_file => "../../asm/recop_src/rawOutput"&integer'image(recop_id)&".mif",
--		intended_device_family => "Cyclone IV E",
--		read_during_write_mode_mixed_ports => "OLD_DATA",
--		lpm_type => "altsyncram",
--		operation_mode => "ROM",
--		power_up_uninitialized => "FALSE",
--		widthad_a => ram_addr_width,
--		width_a => ram_data_width
--		--width_byteena_a => 1
--	)
--	port map (
--		clock0 => clk,
--		address_a => addr,
--		q_a => data_out
--	);



	altsyncram_component : altsyncram
	GENERIC MAP (
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "rawOutput"&integer'image(recop_id)&".mif",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		maximum_depth => 4096,
		numwords_a => 32768,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M4K",
		widthad_a => 15,
		width_a => 16,
		width_byteena_a => 1
	)
	PORT MAP (
		address_a => addr(14 downto 0),
		clock0 => clk,
		q_a => data_out
	);


end architecture;