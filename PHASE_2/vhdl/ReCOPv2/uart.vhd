library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.recop_types.all;
use work.various_constants.all;
use work.opcodes.all;

entity uart is
port (
clk : in bit_1;
receive : in bit_1;
data_out : out bit_16 := X"0000";
address_out : out bit_16 := X"0000";
reset : in bit_1;
write_en : out bit_1
);
end uart;

architecture beh of uart is
	signal address : bit_16 := X"0000";
	signal data : bit_16 := X"0000";
begin
address_out<=address;
data_out<=data;
process(clk, reset)
	variable byte: integer range 0 to 3 := 0;
	variable state : integer range 0 to 9 := 0;
	variable counter : integer range 0 to 511 := 0;
begin
	if reset = '1' then
		counter := 0;
		state := 0;
		data <= X"0000";
	elsif rising_edge(clk) then
		if counter >= 433 then
			counter := 0;
			case state is
			when 0 =>
				if receive = '0' then
					state := 1;
				end if;
				write_en <= '0';
			when 8 =>
				case byte is
				when 0 =>
					address(7) <= receive;
					write_en <= '0';
				when 1 =>
					address(15) <= receive;
					write_en <= '0';
				when 2 =>
					data(7) <= receive;
					write_en <= '0';
				when 3 =>
					data(15) <= receive;
					write_en <= '1';
				end case;
				byte := byte + 1;
				state := 0;
			when others =>
				write_en <= '0';
				case byte is
				when 0 =>
					address(state-1) <= receive;
				when 1 =>
					address(state+7) <= receive;
				when 2 =>
					data(state-1) <= receive;
				when 3 =>
					data(state+7) <= receive;
				end case;
				state := state +1;
			end case;
		else
			write_en <= '0';
			counter := counter + 1;
		end if;
	end if;
end process;
end beh;