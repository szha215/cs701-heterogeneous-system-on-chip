library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library lpm;
use lpm.lpm_components.all;


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

end architecture;