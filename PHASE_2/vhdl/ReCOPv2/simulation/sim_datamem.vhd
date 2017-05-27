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
--	sim_ram.vhd
--
--	internal memory for JOP3
--	Version for simulation
--
--

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is
	port (
		address		: in std_logic_vector(11 downto 0);
		clock		: in std_logic;
		data		: in std_logic_vector(15 downto 0);
		wren		: in std_logic;
		q			: out std_logic_vector(15 downto 0)
	);
end data_mem ;


--	registered address, wren
--	registered din
--	unregistered dout

architecture sim of data_mem is

	signal reg_data		: std_logic_vector(15 downto 0);
	signal reg_address	: std_logic_vector(11 downto 0);
	signal reg_wren		: std_logic;

	subtype word is std_logic_vector(15 downto 0);
	constant nwords : integer := 4096;
	type ram_type is array(0 to nwords-1) of word;

	shared variable ram : ram_type;

begin

	-- initialize at start with a second process accessing
	-- the shared variable ram
	initialize: process
		variable adr	: natural;
	begin
			write(output, "init ReCOP Program Memory");
			for adr in 0 to nwords-1 loop
				ram(adr) := (others => '0');
			end loop;
			-- we're done, wait forever
			wait;
	end process initialize;

	--
	--	Simulation starts here
	--
	--	register addresses and in data
	process(clock) begin
		if rising_edge(clock) then
			reg_address <= address;
			reg_data <= data;
			reg_wren <= wren;
		end if;
	end process;

	-- read/write process
	process(reg_address, reg_data, reg_wren)
		variable adr : natural;
	begin
		adr := to_integer(unsigned(reg_address));
		if reg_wren='1' then
			ram(adr) := reg_data;
		else
			q <= ram(adr);
		end if;	
	end process;

end sim;
