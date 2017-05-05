library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library lpm;
--use lpm.lpm_components.all;
library altera_mf;
use altera_mf.all;


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

component altsyncram
	generic (
		address_aclr_b		: string;
		address_reg_b		: string;
		clock_enable_input_a		: string;
		clock_enable_input_b		: string;
		clock_enable_output_b		: string;
		init_file	: string;
		intended_device_family		: string;
		lpm_type		: string;
		--numwords_a		: natural;
		--numwords_b		: natural;
		operation_mode		: string;
		outdata_aclr_b		: string;
		outdata_reg_b		: string;
		power_up_uninitialized		: string;
		read_during_write_mode_mixed_ports		: string;
		widthad_a		: natural;
		widthad_b		: natural;
		width_a		: natural;
		width_b		: natural
		--width_byteena_a		: natural
	);
	port (
			aclr0	: in std_logic ;
			address_a	: in std_logic_vector (ram_addr_width - 1  downto 0);
			clock0	: in std_logic ;
			data_a	: in std_logic_vector (ram_data_width - 1 downto 0);
			q_b	: out std_logic_vector (ram_data_width - 1 downto 0);
			wren_a	: in std_logic ;
			address_b	: in std_logic_vector (ram_addr_width - 1 downto 0)
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

ram_a : altsyncram
	generic map (
		address_aclr_b => "CLEAR0",
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_b => "BYPASS",
		init_file => "data_ram.mif",
		intended_device_family => "Cyclone IV E",
		lpm_type => "altsyncram",
		--numwords_a => N,
		--numwords_b => N,
		operation_mode => "DUAL_PORT",
		outdata_aclr_b => "CLEAR0",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		widthad_a => ram_addr_width,
		widthad_b => ram_addr_width,
		width_a => ram_data_width,
		width_b => ram_data_width
		--width_byteena_a => 1
	)
	port map (
		clock0 => clk,
		aclr0 => '0',
		address_a => addr,
		data_a => data_in,
		wren_a => wr_en,
		address_b => addr,
		q_b => data_out
	);





end architecture;