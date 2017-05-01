library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

---------------------------------------------------------------------------------------------------
entity seven_seg is
	port(	clk		: in std_logic;
			reset		: in std_logic;
			d_in		: in std_logic_vector(31 downto 0);  -- [31..16]
			ena		: in std_logic;

			hex0		: out std_logic_vector(6 downto 0);
			hex1		: out std_logic_vector(6 downto 0);
			hex2		: out std_logic_vector(6 downto 0);
			hex3		: out std_logic_vector(6 downto 0);
			hex4		: out std_logic_vector(6 downto 0);
			hex5		: out std_logic_vector(6 downto 0);
			hex6		: out std_logic_vector(6 downto 0);
			hex7		: out std_logic_vector(6 downto 0)
	);

end entity;

---------------------------------------------------------------------------------------------------
architecture behaviour of seven_seg is
begin

process(clk, reset)
begin
	if (reset = '1') then
			hex0 <= (others => '0');
			hex1 <= (others => '1');
			hex2 <= (others => '0');
			hex3 <= (others => '1');
			hex4 <= (others => '0');
			hex5 <= (others => '1');
			hex6 <= (others => '0');
			hex7 <= (others => '1');
	elsif (rising_edge(clk)) then
		if (ena = '1') then
			case (d_in(3 downto 0)) is
				when "0000"=> hex0 <="1000000";  -- '0'
				when "0001"=> hex0 <="1111001";  -- '1'
				when "0010"=> hex0 <="0100100";  -- '2'
				when "0011"=> hex0 <="0110000";  -- '3'
				when "0100"=> hex0 <="0011001";  -- '4' 
				when "0101"=> hex0 <="0010010";  -- '5'
				when "0110"=> hex0 <="0000010";  -- '6'
				when "0111"=> hex0 <="1111000";  -- '7'
				when "1000"=> hex0 <="0000000";  -- '8'
				when "1001"=> hex0 <="0010000";  -- '9'
				when "1010"=> hex0 <="0001000";  -- 'a'
				when "1011"=> hex0 <="0000011";	 -- 'b'
				when "1100"=> hex0 <="1000110";  -- 'c'
				when "1101"=> hex0 <="0100001";  -- 'd'
				when "1110"=> hex0 <="0000110";  -- 'e'
				when "1111"=> hex0 <="0001110";  -- 'f'
				when others=> hex0 <="1111111";
			end case;

			case (d_in(7 downto 4)) is
				when "0000"=> hex1 <="1000000";  -- '0'
				when "0001"=> hex1 <="1111001";  -- '1'
				when "0010"=> hex1 <="0100100";  -- '2'
				when "0011"=> hex1 <="0110000";  -- '3'
				when "0100"=> hex1 <="0011001";  -- '4' 
				when "0101"=> hex1 <="0010010";  -- '5'
				when "0110"=> hex1 <="0000010";  -- '6'
				when "0111"=> hex1 <="1111000";  -- '7'
				when "1000"=> hex1 <="0000000";  -- '8'
				when "1001"=> hex1 <="0010000";  -- '9'
				when "1010"=> hex1 <="0001000";  -- 'a'
				when "1011"=> hex1 <="0000011";	-- 'b'
				when "1100"=> hex1 <="1000110";  -- 'c'
				when "1101"=> hex1 <="0100001";  -- 'd'
				when "1110"=> hex1 <="0000110";  -- 'e'
				when "1111"=> hex1 <="0001110";  -- 'f'
				when others=> hex1 <="1111111";
			end case;

			case (d_in(11 downto 8)) is
				when "0000"=> hex2 <="1000000";  -- '0'
				when "0001"=> hex2 <="1111001";  -- '1'
				when "0010"=> hex2 <="0100100";  -- '2'
				when "0011"=> hex2 <="0110000";  -- '3'
				when "0100"=> hex2 <="0011001";  -- '4' 
				when "0101"=> hex2 <="0010010";  -- '5'
				when "0110"=> hex2 <="0000010";  -- '6'
				when "0111"=> hex2 <="1111000";  -- '7'
				when "1000"=> hex2 <="0000000";  -- '8'
				when "1001"=> hex2 <="0010000";  -- '9'
				when "1010"=> hex2 <="0001000";  -- 'a'
				when "1011"=> hex2 <="0000011";	-- 'b'
				when "1100"=> hex2 <="1000110";  -- 'c'
				when "1101"=> hex2 <="0100001";  -- 'd'
				when "1110"=> hex2 <="0000110";  -- 'e'
				when "1111"=> hex2 <="0001110";  -- 'f'
				when others=> hex2 <="1111111";
			end case;

			case (d_in(15 downto 12)) is
				when "0000"=> hex3 <="1000000";  -- '0'
				when "0001"=> hex3 <="1111001";  -- '1'
				when "0010"=> hex3 <="0100100";  -- '2'
				when "0011"=> hex3 <="0110000";  -- '3'
				when "0100"=> hex3 <="0011001";  -- '4' 
				when "0101"=> hex3 <="0010010";  -- '5'
				when "0110"=> hex3 <="0000010";  -- '6'
				when "0111"=> hex3 <="1111000";  -- '7'
				when "1000"=> hex3 <="0000000";  -- '8'
				when "1001"=> hex3 <="0010000";  -- '9'
				when "1010"=> hex3 <="0001000";  -- 'a'
				when "1011"=> hex3 <="0000011";	-- 'b'
				when "1100"=> hex3 <="1000110";  -- 'c'
				when "1101"=> hex3 <="0100001";  -- 'd'
				when "1110"=> hex3 <="0000110";  -- 'e'
				when "1111"=> hex3 <="0001110";  -- 'f'
				when others=> hex3 <="1111111";
			end case;

			case (d_in(19 downto 16)) is
				when "0000"=> hex4 <="1000000";  -- '0'
				when "0001"=> hex4 <="1111001";  -- '1'
				when "0010"=> hex4 <="0100100";  -- '2'
				when "0011"=> hex4 <="0110000";  -- '3'
				when "0100"=> hex4 <="0011001";  -- '4' 
				when "0101"=> hex4 <="0010010";  -- '5'
				when "0110"=> hex4 <="0000010";  -- '6'
				when "0111"=> hex4 <="1111000";  -- '7'
				when "1000"=> hex4 <="0000000";  -- '8'
				when "1001"=> hex4 <="0010000";  -- '9'
				when "1010"=> hex4 <="0001000";  -- 'a'
				when "1011"=> hex4 <="0000011";	 -- 'b'
				when "1100"=> hex4 <="1000110";  -- 'c'
				when "1101"=> hex4 <="0100001";  -- 'd'
				when "1110"=> hex4 <="0000110";  -- 'e'
				when "1111"=> hex4 <="0001110";  -- 'f'
				when others=> hex4 <="1111111";
			end case;

			case (d_in(23 downto 20)) is
				when "0000"=> hex5 <="1000000";  -- '0'
				when "0001"=> hex5 <="1111001";  -- '1'
				when "0010"=> hex5 <="0100100";  -- '2'
				when "0011"=> hex5 <="0110000";  -- '3'
				when "0100"=> hex5 <="0011001";  -- '4' 
				when "0101"=> hex5 <="0010010";  -- '5'
				when "0110"=> hex5 <="0000010";  -- '6'
				when "0111"=> hex5 <="1111000";  -- '7'
				when "1000"=> hex5 <="0000000";  -- '8'
				when "1001"=> hex5 <="0010000";  -- '9'
				when "1010"=> hex5 <="0001000";  -- 'a'
				when "1011"=> hex5 <="0000011";	-- 'b'
				when "1100"=> hex5 <="1000110";  -- 'c'
				when "1101"=> hex5 <="0100001";  -- 'd'
				when "1110"=> hex5 <="0000110";  -- 'e'
				when "1111"=> hex5 <="0001110";  -- 'f'
				when others=> hex5 <="1111111";
			end case;

			case (d_in(27 downto 24)) is
				when "0000"=> hex6 <="1000000";  -- '0'
				when "0001"=> hex6 <="1111001";  -- '1'
				when "0010"=> hex6 <="0100100";  -- '2'
				when "0011"=> hex6 <="0110000";  -- '3'
				when "0100"=> hex6 <="0011001";  -- '4' 
				when "0101"=> hex6 <="0010010";  -- '5'
				when "0110"=> hex6 <="0000010";  -- '6'
				when "0111"=> hex6 <="1111000";  -- '7'
				when "1000"=> hex6 <="0000000";  -- '8'
				when "1001"=> hex6 <="0010000";  -- '9'
				when "1010"=> hex6 <="0001000";  -- 'a'
				when "1011"=> hex6 <="0000011";	-- 'b'
				when "1100"=> hex6 <="1000110";  -- 'c'
				when "1101"=> hex6 <="0100001";  -- 'd'
				when "1110"=> hex6 <="0000110";  -- 'e'
				when "1111"=> hex6 <="0001110";  -- 'f'
				when others=> hex6 <="0000000";
			end case;

			case (d_in(31 downto 28)) is
				when "0000"=> hex7 <="1000000";  -- '0'
				when "0001"=> hex7 <="1111001";  -- '1'
				when "0010"=> hex7 <="0100100";  -- '2'
				when "0011"=> hex7 <="0110000";  -- '3'
				when "0100"=> hex7 <="0011001";  -- '4' 
				when "0101"=> hex7 <="0010010";  -- '5'
				when "0110"=> hex7 <="0000010";  -- '6'
				when "0111"=> hex7 <="1111000";  -- '7'
				when "1000"=> hex7 <="0000000";  -- '8'
				when "1001"=> hex7 <="0010000";  -- '9'
				when "1010"=> hex7 <="0001000";  -- 'a'
				when "1011"=> hex7 <="0000011";	-- 'b'
				when "1100"=> hex7 <="1000110";  -- 'c'
				when "1101"=> hex7 <="0100001";  -- 'd'
				when "1110"=> hex7 <="0000110";  -- 'e'
				when "1111"=> hex7 <="0001110";  -- 'f'
				when others=> hex7 <="1111111";
			end case;
		end if;
	end if;
end process;

end architecture;