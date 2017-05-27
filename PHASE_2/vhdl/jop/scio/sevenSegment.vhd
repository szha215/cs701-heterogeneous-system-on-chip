--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--      scio_DE2-70_SevenSegment.vhd
--
--
--      2010-06-08      created
--


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;
use work.sc_pack.all;
use work.jop_config.all;

entity sevenSegments is
    generic (cpu_id : integer := 0; cpu_cnt : integer := 1);
    port (
        clk   : in std_logic;
        reset : in std_logic;

--
--      SimpCon IO interface write only
--
        sc_wr      : in std_logic;
        sc_wr_data : in std_logic_vector(31 downto 0);

        sc_rdy_cnt : out unsigned(1 downto 0);
--
--      Segments
--
        oHEX0      : out std_logic_vector(6 downto 0);
        oHEX1      : out std_logic_vector(6 downto 0);
        oHEX2      : out std_logic_vector(6 downto 0);
        oHEX3      : out std_logic_vector(6 downto 0);
        oHEX4      : out std_logic_vector(6 downto 0);
		  oHEX5      : out std_logic_vector(6 downto 0);
        oHEX6      : out std_logic_vector(6 downto 0);
        oHEX7      : out std_logic_vector(6 downto 0)

        );
end sevenSegments;


architecture rtl of sevenSegments is

begin
    
    process(CLK, RESET)
    begin
        if RESET = '1' then
            oHEX0 <= (others => '1');
            oHEX1 <= (others => '1');
            oHEX2 <= (others => '1');
            oHEX3 <= (others => '1');
            oHEX4 <= (others => '1');
            oHEX5 <= (others => '1');
            
        elsif rising_edge(CLK) then
            if sc_wr = '1' then
                case sc_wr_data(3 downto 0) is
                    when "0000" => oHEX0 <= "1000000";
                    when "0001" => oHEX0 <= "1111001";
                    when "0010" => oHEX0 <= "0100100";
                    when "0011" => oHEX0 <= "0110000";
                    when "0100" => oHEX0 <= "0011001";
                    when "0101" => oHEX0 <= "0010010";
                    when "0110" => oHEX0 <= "0000010";
                    when "0111" => oHEX0 <= "1111000";
                    when "1000" => oHEX0 <= "0000000";
                    when "1001" => oHEX0 <= "0010000";					
                    when "1010" => oHEX0 <= "0001000"; -- A
                    when "1011" => oHEX0 <= "0000011"; -- B
                    when "1100" => oHEX0 <= "1000110"; -- C
                    when "1101" => oHEX0 <= "0100001"; -- D
                    when "1110" => oHEX0 <= "0000110"; -- E
                    when "1111" => oHEX0 <= "0001110"; -- F
                    when others => oHEX0 <= "1111111";
                end case;
                case sc_wr_data(7 downto 4) is
                    when "0000" => oHEX1 <= "1000000";
                    when "0001" => oHEX1 <= "1111001";
                    when "0010" => oHEX1 <= "0100100";
                    when "0011" => oHEX1 <= "0110000";
                    when "0100" => oHEX1 <= "0011001";
                    when "0101" => oHEX1 <= "0010010";
                    when "0110" => oHEX1 <= "0000010";
                    when "0111" => oHEX1 <= "1111000";
                    when "1000" => oHEX1 <= "0000000";
                    when "1001" => oHEX1 <= "0010000";
                    when "1010" => oHEX1 <= "0001000"; -- A
                    when "1011" => oHEX1 <= "0000011"; -- B
                    when "1100" => oHEX1 <= "1000110"; -- C
                    when "1101" => oHEX1 <= "0100001"; -- D
                    when "1110" => oHEX1 <= "0000110"; -- E
                    when "1111" => oHEX1 <= "0001110"; -- F
                    when others => oHEX1 <= "1111111";
                end case;
                case sc_wr_data(11 downto 8) is
                    when "0000" => oHEX2 <= "1000000";
                    when "0001" => oHEX2 <= "1111001";
                    when "0010" => oHEX2 <= "0100100";
                    when "0011" => oHEX2 <= "0110000";
                    when "0100" => oHEX2 <= "0011001";
                    when "0101" => oHEX2 <= "0010010";
                    when "0110" => oHEX2 <= "0000010";
                    when "0111" => oHEX2 <= "1111000";
                    when "1000" => oHEX2 <= "0000000";
                    when "1001" => oHEX2 <= "0010000";
                    when "1010" => oHEX2 <= "0001000"; -- A
                    when "1011" => oHEX2 <= "0000011"; -- B
                    when "1100" => oHEX2 <= "1000110"; -- C
                    when "1101" => oHEX2 <= "0100001"; -- D
                    when "1110" => oHEX2 <= "0000110"; -- E
                    when "1111" => oHEX2 <= "0001110"; -- F
                    when others => oHEX2 <= "1111111";
                end case;
                case sc_wr_data(15 downto 12) is
                    when "0000" => oHEX3 <= "1000000";
                    when "0001" => oHEX3 <= "1111001";
                    when "0010" => oHEX3 <= "0100100";
                    when "0011" => oHEX3 <= "0110000";
                    when "0100" => oHEX3 <= "0011001";
                    when "0101" => oHEX3 <= "0010010";
                    when "0110" => oHEX3 <= "0000010";
                    when "0111" => oHEX3 <= "1111000";
                    when "1000" => oHEX3 <= "0000000";
                    when "1001" => oHEX3 <= "0010000";
                    when "1010" => oHEX3 <= "0001000"; -- A
                    when "1011" => oHEX3 <= "0000011"; -- B
                    when "1100" => oHEX3 <= "1000110"; -- C
                    when "1101" => oHEX3 <= "0100001"; -- D
                    when "1110" => oHEX3 <= "0000110"; -- E
                    when "1111" => oHEX3 <= "0001110"; -- F
                    when others => oHEX3 <= "1111111";
                end case;
                case sc_wr_data(19 downto 16) is
                    when "0000" => oHEX4 <= "1000000";
                    when "0001" => oHEX4 <= "1111001";
                    when "0010" => oHEX4 <= "0100100";
                    when "0011" => oHEX4 <= "0110000";
                    when "0100" => oHEX4 <= "0011001";
                    when "0101" => oHEX4 <= "0010010";
                    when "0110" => oHEX4 <= "0000010";
                    when "0111" => oHEX4 <= "1111000";
                    when "1000" => oHEX4 <= "0000000";
                    when "1001" => oHEX4 <= "0010000";
                    when "1010" => oHEX4 <= "0001000"; -- A
                    when "1011" => oHEX4 <= "0000011"; -- B
                    when "1100" => oHEX4 <= "1000110"; -- C
                    when "1101" => oHEX4 <= "0100001"; -- D
                    when "1110" => oHEX4 <= "0000110"; -- E
                    when "1111" => oHEX4 <= "0001110"; -- F
                    when others => oHEX4 <= "1111111";
                end case;
                case sc_wr_data(23 downto 20) is
                    when "0000" => oHEX5 <= "1000000";
                    when "0001" => oHEX5 <= "1111001";
                    when "0010" => oHEX5 <= "0100100";
                    when "0011" => oHEX5 <= "0110000";
                    when "0100" => oHEX5 <= "0011001";
                    when "0101" => oHEX5 <= "0010010";
                    when "0110" => oHEX5 <= "0000010";
                    when "0111" => oHEX5 <= "1111000";
                    when "1000" => oHEX5 <= "0000000";
                    when "1001" => oHEX5 <= "0010000";
                    when "1010" => oHEX5 <= "0001000"; -- A
                    when "1011" => oHEX5 <= "0000011"; -- B
                    when "1100" => oHEX5 <= "1000110"; -- C
                    when "1101" => oHEX5 <= "0100001"; -- D
                    when "1110" => oHEX5 <= "0000110"; -- E
                    when "1111" => oHEX5 <= "0001110"; -- F
                    when others => oHEX5 <= "1111111";
                end case;
                case sc_wr_data(27 downto 24) is
                    when "0000" => oHEX6 <= "1000000";
                    when "0001" => oHEX6 <= "1111001";
                    when "0010" => oHEX6 <= "0100100";
                    when "0011" => oHEX6 <= "0110000";
                    when "0100" => oHEX6 <= "0011001";
                    when "0101" => oHEX6 <= "0010010";
                    when "0110" => oHEX6 <= "0000010";
                    when "0111" => oHEX6 <= "1111000";
                    when "1000" => oHEX6 <= "0000000";
                    when "1001" => oHEX6 <= "0010000";
                    when "1010" => oHEX6 <= "0001000"; -- A
                    when "1011" => oHEX6 <= "0000011"; -- B
                    when "1100" => oHEX6 <= "1000110"; -- C
                    when "1101" => oHEX6 <= "0100001"; -- D
                    when "1110" => oHEX6 <= "0000110"; -- E
                    when "1111" => oHEX6 <= "0001110"; -- F
                    when others => oHEX6 <= "1111111";
                end case;
                case sc_wr_data(31 downto 28) is
                    when "0000" => oHEX5 <= "1000000";
                    when "0001" => oHEX7 <= "1111001";
                    when "0010" => oHEX7 <= "0100100";
                    when "0011" => oHEX7 <= "0110000";
                    when "0100" => oHEX7 <= "0011001";
                    when "0101" => oHEX7 <= "0010010";
                    when "0110" => oHEX7 <= "0000010";
                    when "0111" => oHEX7 <= "1111000";
                    when "1000" => oHEX7 <= "0000000";
                    when "1001" => oHEX7 <= "0010000";
                    when "1010" => oHEX7 <= "0001000"; -- A
                    when "1011" => oHEX7 <= "0000011"; -- B
                    when "1100" => oHEX7 <= "1000110"; -- C
                    when "1101" => oHEX7 <= "0100001"; -- D
                    when "1110" => oHEX7 <= "0000110"; -- E
                    when "1111" => oHEX7 <= "0001110"; -- F
                    when others => oHEX7 <= "1111111";
                end case;
            end if;
        end if;
    end process;

end rtl;
