library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

---------------------------------------------------------------------------------------------------
entity multiplier is
	generic( 
	in_width	: positive;
	res_witdh	: positive;
	result_lowbit	: natural
	);
	port(
	a		: in std_logic_vector(in_width-1 downto 0);
	b		: in std_logic_vector(in_width-1 downto 0);
	res	: out std_logic_vector(res_witdh-1 downto 0)
	);
end entity;

---------------------------------------------------------------------------------------------------
architecture behaviour of multiplier is 
	signal s_res	: std_logic_vector(in_width+in_width-1 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
begin

	s_res <= unsigned(a) * unsigned(b);
	res <= (res_witdh - 1 downto s_res'length => '0') & s_res(in_width+in_width-1 downto 0);

end architecture;