library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library lpm;
--use lpm.lpm_components.all;
library altera_mf;
library work;
use work.all;


entity prog_mem is
generic(
	constant ram_addr_width : positive := 16;
	constant ram_data_width : positive := 16
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
		init_file	: string;
		intended_device_family		: string;
		lpm_type		: string;
		operation_mode		: string;
		power_up_uninitialized			: string;
		read_during_write_mode_mixed_ports		: string;
		widthad_a		: natural;
		width_a			: natural
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

ram_a : altsyncram
	generic map (
		
		init_file => "prog_mem.mif",
		intended_device_family => "Cyclone IV E",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		lpm_type => "altsyncram",
		operation_mode => "ROM",
		power_up_uninitialized => "FALSE",
		widthad_a => ram_addr_width,
		width_a => ram_data_width
		--width_byteena_a => 1
	)
	port map (
		clock0 => clk,
		address_a => addr,
		q_a => data_out
	);





end architecture;