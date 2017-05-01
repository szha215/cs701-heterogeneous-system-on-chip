library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

---------------------------------------------------------------------------------------------------
entity average_filter is
	generic(
		window_size	: positive := 4;
		data_width	: positive := 16
	);
	port (
		clk	: in std_logic;
		reset	: in std_logic;
		data	: in std_logic_vector(data_width - 1 downto 0);

		avg	: out std_logic_vector(data_width - 1 downto 0)
	);
end entity ; -- average_filter

---------------------------------------------------------------------------------------------------
architecture behaviour of average_filter is

type data_vector is array (0 to window_size - 1) of std_logic_vector(data_width - 1 downto 0);
signal s_values	: data_vector := (others => (others =>'0'));

signal s_count		: std_logic_vector(integer(ceil(log2(real(window_size)))) - 1 downto 0) := (others => '0');
signal s_sum		: std_logic_vector(data_width + 2 downto 0) := (others => '0');
signal s_avg		: std_logic_vector(data_width - 1 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
begin

assert ((window_size = 4 or window_size = 8)) report "WINDOW SIZE MUST BE 4 or 8" severity failure;

add_gen4 : if (window_size = 4) generate
		s_sum <= ((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(0)) + 
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(1)) + 
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(2)) + 
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(3));
	end generate;

add_gen8 : if (window_size = 8) generate
		s_sum <= ((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(0)) + 
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(1)) + 
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(2)) + 
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(3)) +
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(4)) +
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(5)) + 
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(6)) + 
					((s_sum'length - 1 downto s_values(0)'length => '0') & s_values(7)); 
	end generate;

filter_process : process(clk, reset, data)
begin
	if (reset = '1') then
		s_values <= (others => (others =>'0'));
		s_count <= (others => '0');

	elsif (rising_edge(clk)) then

		s_values(to_integer(unsigned(s_count))) <= data;
		s_count <= s_count + '1';

	end if;
end process; -- filter_process

---------------------------------------------------------------------------------------------------

-- Left shift by 2 or 3 bits depending on window_size
s_avg <= s_sum(data_width + integer(ceil(log2(real(window_size)))) - 1 downto integer(ceil(log2(real(window_size)))));
avg <= s_avg;

end architecture; -- behaviour