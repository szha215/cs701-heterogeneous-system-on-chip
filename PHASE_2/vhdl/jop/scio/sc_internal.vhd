-- This file is for an internal memory


Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.jop_types.all;
use work.sc_pack.all;

entity sc_mem_int is
	generic (
		element_size : integer := 32; 
		memory_depth : integer := 1000;
		main_mem : boolean := false;
		jop_id : integer := 0
	);
	port (

		clk 					: in  std_logic;
		reset					: in  std_logic;
		
	--	SimpCon memory interface
		sc_mem_out			: in  sc_out_type;
		sc_mem_in			: out sc_in_type
	);
end sc_mem_int;

architecture rtl of sc_mem_int is

type state_type is (idl, done, rd1);

type memory is array(2**memory_depth-1 downto 0) of std_logic_vector(element_size-1 downto 0);
signal ram : memory := (others => (others => '0'));

signal state : state_type;
signal q_out : std_logic_vector(31 downto 0);
signal addressreg : std_logic_vector(memory_depth-1 downto 0) := (others=>'0');
	
begin
	
	fsm: process(clk, reset)
	variable rd : std_logic := '0';
	begin
		if reset = '1' then
			--ram <= (others => (others => '0'));
			sc_mem_in.rdy_cnt <= "00";
			sc_mem_in.rd_data <= (others=>'0');
		elsif rising_edge(clk) then
			case state is
				when idl =>
					if sc_mem_out.rd = '1' then
						sc_mem_in.rdy_cnt <= "11";
						addressreg <= sc_mem_out.address(memory_depth-1 downto 0);
						state <= rd1;
					elsif sc_mem_out.wr='1' then
						sc_mem_in.rdy_cnt <= "11";
						ram(to_integer(unsigned(sc_mem_out.address(memory_depth-1 downto 0)))) <= sc_mem_out.wr_data;
						state <= done;
					else
						sc_mem_in.rdy_cnt <= "00";
					end if;
				when rd1 =>
				  rd := '1';
					state <= done;
				when done =>
				  if (rd = '1') then
				    sc_mem_in.rd_data <= q_out;
				    rd := '0';  
				  end if;
					sc_mem_in.rdy_cnt <= "00";
					state <= idl;
			end case;
			q_out <= ram(to_integer(unsigned(addressreg)));
			
		end if;
	end process;
end rtl;