-------------------------------------------------------------
-- router_ST_100.vhd
-- This is an auto generated file, do not edit by hand.
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.noc_types.all;

entity router_ST_100 is
	generic (
		NI_NUM	: natural
		);
	port (
		count	: in unsigned(7 downto 0);
		sels	: out select_signals
		);
end router_ST_100;

architecture data of router_ST_100 is
begin -- data

process(count) begin

	sels(D) <= D;
	case count is

		when "00000000" =>
			sels(N) <= L;
			sels(E) <= D;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= D;
		when "00000001" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= D;
		when "00000010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= D;
			sels(L) <= D;
		when "00000011" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= N;
			sels(L) <= D;
		when "00000100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00000101" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= W;
			sels(W) <= E;
			sels(L) <= N;
		when "00000110" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= S;
		when "00000111" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= L;
			sels(L) <= E;
		when "00001000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00001001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= N;
		when "00001010" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= W;
		when "00001011" =>
			sels(N) <= E;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= S;
			sels(L) <= D;
		when "00001100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00001101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= N;
			sels(L) <= E;
		when "00001110" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= N;
		when "00001111" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= W;
		when "00010000" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= S;
		when "00010001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= N;
			sels(L) <= E;
		when "00010010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00010011" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00010100" =>
			sels(N) <= S;
			sels(E) <= D;
			sels(S) <= W;
			sels(W) <= E;
			sels(L) <= N;
		when "00010101" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "00010110" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= S;
			sels(L) <= D;
		when "00010111" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00011000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= N;
		when "00011001" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= W;
		when "00011010" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= S;
			sels(L) <= E;
		when "00011011" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= L;
			sels(L) <= E;
		when "00011100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= N;
		when "00011101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= D;
		when "00011110" =>
			sels(N) <= E;
			sels(E) <= S;
			sels(S) <= N;
			sels(W) <= L;
			sels(L) <= W;
		when "00011111" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00100000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00100001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= N;
			sels(L) <= E;
		when "00100010" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= W;
		when "00100011" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= S;
		when "00100100" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= W;
			sels(W) <= N;
			sels(L) <= E;
		when "00100101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= N;
		when "00100110" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00100111" =>
			sels(N) <= W;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= S;
			sels(L) <= E;
		when "00101000" =>
			sels(N) <= S;
			sels(E) <= N;
			sels(S) <= W;
			sels(W) <= E;
			sels(L) <= D;
		when "00101001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= N;
		when "00101010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00101011" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= N;
			sels(L) <= E;
		when "00101100" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= S;
		when "00101101" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= W;
		when "00101110" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= W;
			sels(W) <= E;
			sels(L) <= D;
		when "00101111" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= L;
			sels(L) <= E;
		when "00110000" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= S;
			sels(L) <= E;
		when "00110001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00110010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= N;
		when "00110011" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= W;
		when "00110100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= L;
			sels(L) <= E;
		when "00110101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= D;
		when "00110110" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= D;
		when "00110111" =>
			sels(N) <= E;
			sels(E) <= S;
			sels(S) <= N;
			sels(W) <= L;
			sels(L) <= W;
		when "00111000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "00111001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "00111010" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= N;
			sels(L) <= W;
		when "00111011" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= S;
		when "00111100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= D;
			sels(L) <= E;
		when "00111101" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= W;
			sels(W) <= N;
			sels(L) <= D;
		when "00111110" =>
			sels(N) <= D;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= S;
			sels(L) <= E;
		when "00111111" =>
			sels(N) <= W;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "01000000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "01000001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= N;
		when "01000010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "01000011" =>
			sels(N) <= S;
			sels(E) <= N;
			sels(S) <= W;
			sels(W) <= L;
			sels(L) <= D;
		when "01000100" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= S;
		when "01000101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "01000110" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= N;
		when "01000111" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= N;
			sels(L) <= E;
		when "01001000" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= W;
		when "01001001" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= S;
			sels(L) <= E;
		when "01001010" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= W;
			sels(W) <= E;
			sels(L) <= D;
		when "01001011" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "01001100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= D;
		when "01001101" =>
			sels(N) <= D;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= S;
			sels(L) <= D;
		when "01001110" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= N;
		when "01001111" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= W;
		when "01010000" =>
			sels(N) <= W;
			sels(E) <= S;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= E;
		when "01010001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= D;
			sels(L) <= D;
		when "01010010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= D;
		when "01010011" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= N;
			sels(L) <= D;
		when "01010100" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= W;
		when "01010101" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= S;
		when "01010110" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= N;
			sels(L) <= E;
		when "01010111" =>
			sels(N) <= S;
			sels(E) <= D;
			sels(S) <= W;
			sels(W) <= E;
			sels(L) <= D;
		when "01011000" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "01011001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= D;
		when "01011010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= D;
			sels(L) <= N;
		when "01011011" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= W;
		when "01011100" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= W;
		when "01011101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= D;
		when "01011110" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= N;
			sels(L) <= W;
		when "01011111" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= D;
			sels(L) <= E;
		when "01100000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= D;
		when "01100001" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= S;
			sels(L) <= D;
		when "01100010" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= W;
			sels(W) <= N;
			sels(L) <= E;
		when "01100011" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "01100100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= N;
		when "01100101" =>
			sels(N) <= D;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= S;
			sels(L) <= D;
		when "01100110" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= D;
		when "01100111" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= W;
			sels(W) <= N;
			sels(L) <= E;
		when "01101000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= N;
		when "01101001" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= S;
			sels(L) <= E;
		when "01101010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= E;
			sels(L) <= D;
		when "01101011" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= N;
			sels(W) <= E;
			sels(L) <= W;
		when "01101100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= N;
			sels(L) <= E;
		when "01101101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= L;
			sels(W) <= D;
			sels(L) <= E;
		when "01101110" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= D;
			sels(W) <= N;
			sels(L) <= W;
		when "01101111" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= D;
		when "01110000" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= W;
		when "01110001" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= E;
		when "01110010" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= W;
			sels(W) <= D;
			sels(L) <= D;
		when "01110011" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= W;
		when "01110100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= D;
		when "01110101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= N;
		when "01110110" =>
			sels(N) <= L;
			sels(E) <= D;
			sels(S) <= W;
			sels(W) <= S;
			sels(L) <= D;
		when "01110111" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "01111000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= N;
		when "01111001" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= S;
			sels(L) <= D;
		when "01111010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= D;
		when "01111011" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= W;
			sels(W) <= D;
			sels(L) <= E;
		when "01111100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= N;
		when "01111101" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= D;
		when "01111110" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= S;
		when "01111111" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= S;
			sels(L) <= D;
		when "10000000" =>
			sels(N) <= D;
			sels(E) <= S;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= W;
		when "10000001" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= D;
		when "10000010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= E;
		when "10000011" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= W;
		when "10000100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= D;
		when "10000101" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= W;
		when "10000110" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= W;
			sels(W) <= D;
			sels(L) <= D;
		when "10000111" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= W;
		when "10001000" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= D;
		when "10001001" =>
			sels(N) <= L;
			sels(E) <= D;
			sels(S) <= W;
			sels(W) <= S;
			sels(L) <= N;
		when "10001010" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "10001011" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= S;
			sels(L) <= N;
		when "10001100" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= E;
			sels(L) <= D;
		when "10001101" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= W;
			sels(W) <= D;
			sels(L) <= E;
		when "10001110" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= N;
		when "10001111" =>
			sels(N) <= D;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= S;
		when "10010000" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= D;
		when "10010001" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= W;
		when "10010010" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= D;
		when "10010011" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= W;
		when "10010100" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= W;
		when "10010101" =>
			sels(N) <= L;
			sels(E) <= D;
			sels(S) <= W;
			sels(W) <= S;
			sels(L) <= D;
		when "10010110" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= N;
			sels(W) <= D;
			sels(L) <= E;
		when "10010111" =>
			sels(N) <= S;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= N;
		when "10011000" =>
			sels(N) <= L;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= S;
		when "10011001" =>
			sels(N) <= L;
			sels(E) <= S;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= W;
		when "10011010" =>
			sels(N) <= S;
			sels(E) <= L;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= W;
		when "10011011" =>
			sels(N) <= D;
			sels(E) <= W;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= S;
		when "10011100" =>
			sels(N) <= D;
			sels(E) <= D;
			sels(S) <= D;
			sels(W) <= D;
			sels(L) <= W;
		when others => sels <= (others => D);

	end case;
end process;

end data;
