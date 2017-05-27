library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_holder is
port(
	clk	: in std_logic;
	reset	: in std_logic;
	iSigI	: in std_logic_vector(15 downto 0);
	iSigII	: in std_logic_vector(15 downto 0);
	oSig	: out std_logic_vector(15 downto 0)
);
end signal_holder;

--architecture beh of signal_holder is
--	signal sig : std_logic_vector(15 downto 0);
--begin
--	process(clk, reset)
--		variable delay_cnt : integer range 0 to 16777215 := 0;
--	begin
--		if reset = '1' then
--			sig 			<= (others => '0');
--			delay_cnt	:= 0;
--		elsif rising_edge(clk) then
--			delay_cnt := delay_cnt + 1;
--			if delay_cnt < 16777215 then
--				sig	<= sig or iSigI;
--			else
--				sig	<= iSigI;
--			end if;
--		end if;
--		oSig <= sig;
--	end process;
--end architecture;

--architecture beh of signal_holder is
--begin
--	process(clk, reset)
--		variable dcall_cnt : integer range 0 to 65535 := 0;
--		variable last_call : std_logic_vector(15 downto 0) := (others => '0'); 
--	begin
--		if reset = '1' then
--			dcall_cnt	:= 0;
--			last_call	:= (others => '0'); 
--		elsif rising_edge(clk) then
--			if iSigI(15) = '1' then
--				case to_integer(unsigned(iSigI(11 downto 0))) is
--
----					when 0 =>	dcall_cnt	:= dcall_cnt + 1;
--
----					when 1 =>	if iSigI /= last_call then
----										dcall_cnt	:= dcall_cnt + 1;
----									end if;
----									last_call	:= iSigI;
------					when 3 =>	dcall_cnt	:= dcall_cnt + 8;
------					when 5 =>	dcall_cnt	:= dcall_cnt + 64;
----					
----					when 7 =>	if iSigI /= last_call then
----										dcall_cnt	:= dcall_cnt + 2;
----									end if;
----									last_call	:= iSigI;
----					when 11 =>	dcall_cnt	:= dcall_cnt + 4;
----					when 12 =>	dcall_cnt	:= dcall_cnt + 8;
----					when 13 =>	dcall_cnt	:= dcall_cnt + 16;
--					
----					when 14 =>	dcall_cnt	:= dcall_cnt + 512;
----					when 18 =>	dcall_cnt	:= dcall_cnt + 512;
----					when 19 =>	dcall_cnt	:= dcall_cnt + 512;
----					when 20 =>	dcall_cnt	:= dcall_cnt + 512;
--					
----					when 42 =>	dcall_cnt	:= dcall_cnt + 8;
----					when 46 =>	dcall_cnt	:= dcall_cnt + 8;
----					when 47 =>	dcall_cnt	:= dcall_cnt + 8;
----					when 48 =>	dcall_cnt	:= dcall_cnt + 8;
--					
----					when 70 =>	dcall_cnt	:= dcall_cnt + 64;
----					when 74 =>	dcall_cnt	:= dcall_cnt + 64;
----					when 75 =>	dcall_cnt	:= dcall_cnt + 64;
----					when 76 =>	dcall_cnt	:= dcall_cnt + 64;
--					
----					when 35 =>	dcall_cnt	:= dcall_cnt + 1;
----					when 36 =>	dcall_cnt	:= dcall_cnt + 1;
----					when 37 =>	dcall_cnt	:= dcall_cnt + 1;
----					when 38 =>	dcall_cnt	:= dcall_cnt + 1;
--					when others =>	
--				end case;
--			end if;
--		end if;
--		oSig <= std_logic_vector(to_unsigned(dcall_cnt, 16));
--	end process;
--end architecture;

--architecture beh of signal_holder is
--begin
--	process(clk, reset)
--		variable result_cnt : integer range 0 to 65536 := 0;
--	begin
--		if reset = '1' then
--			result_cnt	:= 0;
--		elsif rising_edge(clk) then
--			if iSigI(15) = '1' then
--				result_cnt	:= result_cnt + 1;
--			end if;
--		end if;
--		oSig <= std_logic_vector(to_unsigned(result_cnt, 16));
--	end process;
--end architecture;


------------------------------------------------------------------------------------
----   track difference between number of datacalls issued and results returned   --
------------------------------------------------------------------------------------
--architecture beh of signal_holder is
--begin
--	process(clk, reset)
--		variable diff : integer range 0 to 65536 := 0;
--	begin
--		if reset = '1' then
--			diff	:= 0;
--		elsif rising_edge(clk) then
--			if iSigI(15) = '1' then
--				diff	:= diff + 1;
--			end if;
--			if iSigII(1) = '1' then
--				diff := diff -1;
--			end if;
--		end if;
--		oSig <= std_logic_vector(to_unsigned(diff, 16));
--	end process;
--end architecture;


architecture beh of signal_holder is
begin
	process(clk, reset)
		variable indicator : integer range 0 to 65536 := 0;
	begin
		if reset = '1' then
			indicator	:= 0;
		elsif rising_edge(clk) then
			if iSigI(1) = '1' then
				indicator := indicator + 1;
			end if;
--			if iSigI = "0000000000001110" then
--				indicator := indicator + 4;
--			end if;
			
			if iSigII = "1000000000000000" then
				indicator := indicator + 128;
			end if;
			if iSigII = "1000000000000001" then
				indicator := indicator + 512;
			end if;
			if iSigII = "1000000000000010" then
				indicator := indicator + 2048;
			end if;
			if iSigII = "1000000000000011" then
				indicator := indicator + 8192;
			end if;
		end if;
		oSig <= std_logic_vector(to_unsigned(indicator, 16));
	end process;
end architecture;




----------------------------------------------------------------------------
--   find minmal number of clock cycles between reoccuring input signal   --
----------------------------------------------------------------------------
--architecture beh of signal_holder is
--begin
--	process(clk, reset)
--		variable cycle_count : integer range 0 to 65535 := 0;
--		variable min_count : integer range 0 to 65535 := 65535;
--	begin
--		if reset = '1' then
--			cycle_count	:= 0;
--			min_count	:= 65535;
--		elsif rising_edge(clk) then
--			if iSigII(1) = '1' then
--				if cycle_count < min_count  and cycle_count /= 0 then
--					min_count := cycle_count;
--				end if;
--				cycle_count	:= 0;
--			end if;
--			cycle_count	:= cycle_count + 1;
--
--		end if;
--		oSig <= std_logic_vector(to_unsigned(min_count, 16));
--	end process;
--end architecture;