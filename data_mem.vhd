library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library lpm;
use lpm.lpm_components.all;
--library altera_mf;
--use altera_mf.all;


entity data_mem is
generic(
	constant ram_addr_width : positive := 16;
	constant ram_data_width : positive := 16
);

port (
	wr_en		:	in std_logic;
	addr		:	in std_logic_vector(ram_addr_width - 1 downto 0);
	data_in	:	in std_logic_vector(ram_data_width - 1 downto 0);

	data_out	:	out std_logic_vector(ram_data_width - 1 downto 0)		
) ;
end entity ; -- data_mem

architecture behaviour of data_mem is
begin

ram: lpm_ram_dq
	generic map(
		lpm_widthad => ram_addr_width,
		lpm_width	=>	ram_data_width,
		lpm_indata	=>	"UNREGISTERED",
		lpm_outdata => "UNREGISTERED",
		lpm_address_control => "UNREGISTERED",
		lpm_file 	=> "data_ram.hex"
		)
	port map(
		data 		=> data_in,
		address 	=> addr,
		we 		=> wr_en,
		q 			=> data_out
	);

--ram : altsyncram
--	generic map (
--		address_aclr_b => "CLEAR0",
--		address_reg_b => "CLOCK0",
--		clock_enable_input_a => "BYPASS",
--		clock_enable_input_b => "BYPASS",
--		clock_enable_output_b => "BYPASS",
--		intended_device_family => "Cyclone IV E",
--		lpm_type => "altsyncram",
--		operation_mode => "DUAL_PORT",
--		outdata_aclr_b => "CLEAR0",
--		outdata_reg_b => "UNREGISTERED",
--		power_up_uninitialized => "FALSE",
--		read_during_write_mode_mixed_ports => "OLD_DATA",
--		widthad_a => ram_addr_width,
--		widthad_b => ram_addr_width,
--		width_a => ram_data_width,
--		width_byteena_a => 1
--	)
--	port map (
--		clock0 => clk,
--		address_a => addr,
--		data_a => data_in,
--		wren_a => wr_en,
--		address_b => s_pointer(integer(ceil(log2(real(N)))) - 1 downto 0),
--		q_b => s_reg_a_out
--	);

end architecture;