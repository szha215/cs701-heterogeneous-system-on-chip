library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

---------------------------------------------------------------------------------------------------
entity fake_tdm_counter is
	generic(
		constant tdm_slot_width	: positive := 4
	);
	port(
		clk	: in std_logic;

		tdm_slot	: out std_logic_vector(tdm_slot_width - 1 downto 0)
	);
end entity fake_tdm_counter;

---------------------------------------------------------------------------------------------------
architecture behaviour of fake_tdm_counter is

signal count	: std_logic_vector(tdm_slot_width - 1 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
begin

---------------------------------------------------------------------------------------------------
counter : process(clk)
begin
	if (rising_edge(clk)) then
		count <= count + '1';
	end if;
end process;

---------------------------------------------------------------------------------------------------

tdm_slot <= count;

end architecture;
