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
--	sim_rom.vhd
--
--	A 'faster' simulation version of the JVM ROM.
--
--

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prog_mem is
	generic (
		recop_id 	: integer
	);
	port (
		address		: in std_logic_vector(13 downto 0);
		clock		: in std_logic;
		q			: out std_logic_vector(15 downto 0)
);
end prog_mem ;

architecture sim of prog_mem is

	signal reg_address	: std_logic_vector(13 downto 0);

	subtype word is std_logic_vector(15 downto 0);
	constant nwords : integer := 16384;
	type ram_type is array(0 to nwords-1) of word;

	shared variable ram : ram_type;

begin

	-- initialize at start with a second process accessing
	-- the shared variable ram
	initialize: process
		variable address	: natural;
		file memfile		: text is "../modelsim/rawOutput"&integer'image(recop_id)&".dat";
		variable memline	: line; 
		variable val		: integer;
	begin
		write(output, "load ReCOP Program Memory...");
		for address in 0 to nwords-1 loop
			if endfile(memfile) then
				exit;
			end if;
			readline(memfile, memline);
			read(memline, val);
			ram(address) := std_logic_vector(to_unsigned(val, 16));
		end loop;
		file_close(memfile);
		-- we're done, wait forever
		wait;
	end process initialize;

	--
	--	Simulation starts here
	--
	-- read process
	process(clock)
	begin
		if rising_edge(clock) then
			q <= ram(to_integer(unsigned(address)));
		end if;
	end process;

end sim;
