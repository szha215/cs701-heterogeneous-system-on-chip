LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity tb_fifo_ram_cell is
end tb_fifo_ram_cell;

architecture test of tb_fifo_ram_cell is

	component fifo_ram_cell IS
		PORT
		(
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			rdaddress		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			wraddress		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			wren		: IN STD_LOGIC  := '0';
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END component;

	signal tb_clk			: std_logic := '0';
	signal tb_data			: std_logic_vector(31 downto 0) := x"00000000";
	signal tb_rdaddress	: std_logic_vector(1 downto 0) := "00";
	signal tb_wraddress	: std_logic_vector(1 downto 0) := "00";
	signal tb_wren				: std_logic := '0';
	signal tb_q				: std_logic_vector(31 downto 0);
	
	
begin

	dut : fifo_ram_cell
	port map(
		clock			=> tb_clk,
		data			=> tb_data,
		rdaddress	=> tb_rdaddress,
		wraddress	=> tb_wraddress,
		wren			=> tb_wren,
		q				=> tb_q
	);
	
	clk_gen: process
	begin
		wait for 1 ns;
		tb_clk <= not tb_clk;
	end process;
	
	gen_stimuli: process
	begin
		tb_data <= x"00000000";
		tb_rdaddress <= "00";
		tb_wraddress <= "00";
		tb_wren <= '0';
		wait for 15 ns;
		tb_data <= x"00000001";
		tb_rdaddress <= "00";
		tb_wraddress <= "00";
		tb_wren <= '1', '0' after 2 ns;
		wait for 10 ns;
		tb_rdaddress <= "01";
		wait for 10 ns;
		tb_data <= x"00000002";
		tb_wraddress <= "01";
		tb_wren <= '1', '0' after 2 ns;
		wait for 10 ns;
		tb_data <= x"00000003";
		tb_wraddress <= "10";
		tb_wren <= '1', '0' after 2 ns;
		wait for 10 ns;
		tb_data <= x"00000004";
		tb_rdaddress <= "10";
		tb_wraddress <= "11";
		tb_wren <= '1', '0' after 2 ns;
		wait for 10 ns;
		tb_data <= x"00000005";
		tb_rdaddress <= "00";
		tb_wraddress <= "00";
		tb_wren <= '1', '0' after 2 ns;
		wait for 20 ns;
	end process;

end architecture;