library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

---------------------------------------------------------------------------------------------------
entity test_average_filter is
end entity; -- test_average_filter

---------------------------------------------------------------------------------------------------
architecture behaviour of test_average_filter is

constant t_clk_period : time := 20 ns;

signal t_clk, t_reset	: std_logic;
signal t_data	: std_logic_vector(15 downto 0) := (others => '0');
signal t_avg	: std_logic_vector(15 downto 0) := (others => '0');
signal t_pointer, t_wr_pointer	: std_logic_vector(8 downto 0) := (others => '0');
signal reg_a_ld	: std_logic := '0';

---------------------------------------------------------------------------------------------------
component average_filter is
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
end component; -- average_filter

component altsyncram
	generic (
		address_aclr_b		: string;
		address_reg_b		: string;
		clock_enable_input_a		: string;
		clock_enable_input_b		: string;
		clock_enable_output_b		: string;
		init_file	: string;
		intended_device_family		: string;
		lpm_type		: string;
		numwords_a		: natural;
		numwords_b		: natural;
		operation_mode		: string;
		outdata_aclr_b		: string;
		outdata_reg_b		: string;
		power_up_uninitialized		: string;
		read_during_write_mode_mixed_ports		: string;
		widthad_a		: natural;
		widthad_b		: natural;
		width_a		: natural;
		width_b		: natural;
		width_byteena_a		: natural
	);
	port (
			aclr0	: in std_logic ;
			address_a	: in std_logic_vector (8 downto 0);
			clock0	: in std_logic ;
			data_a	: in std_logic_vector (15 downto 0);
			q_b	: out std_logic_vector (15 downto 0);
			wren_a	: in std_logic ;
			address_b	: in std_logic_vector (8 downto 0)
	);
	end component;

---------------------------------------------------------------------------------------------------
begin

filter : average_filter
generic map(
	window_size	=> 4,
	data_width	=> 16
)
port map(
	clk	=> t_clk,
	reset => t_reset,
	data	=> t_data,

	avg	=> t_avg
);

ram_a : altsyncram
	generic map (
		address_aclr_b => "CLEAR0",
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_b => "BYPASS",
		init_file => "ram_a.mif",
		intended_device_family => "Cyclone IV E",
		lpm_type => "altsyncram",
		numwords_a => 8,
		numwords_b => 8,
		operation_mode => "DUAL_PORT",
		outdata_aclr_b => "CLEAR0",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		widthad_a => integer(ceil(log2(real(8)))),
		widthad_b => integer(ceil(log2(real(8)))),
		width_a => 16,
		width_b => 16,
		width_byteena_a => 1
	)
	port map (
		clock0 => t_clk,
		aclr0 => '0',
		address_a => t_wr_pointer(integer(ceil(log2(real(8)))) - 1 downto 0),
		data_a => t_avg,
		wren_a => reg_a_ld,
		address_b => t_pointer(integer(ceil(log2(real(8)))) - 1 downto 0),
		q_b => t_data
	);

--ram_b : altsyncram
--	generic map (
--		address_aclr_b => "CLEAR0",
--		address_reg_b => "CLOCK0",
--		clock_enable_input_a => "BYPASS",
--		clock_enable_input_b => "BYPASS",
--		clock_enable_output_b => "BYPASS",
--		init_file => "ram_b.mif",
--		intended_device_family => "Cyclone IV E",
--		lpm_type => "altsyncram",
--		numwords_a => 8,
--		numwords_b => 8,
--		operation_mode => "DUAL_PORT",
--		outdata_aclr_b => "CLEAR0",
--		outdata_reg_b => "UNREGISTERED",
--		power_up_uninitialized => "FALSE",
--		read_during_write_mode_mixed_ports => "OLD_DATA",
--		widthad_a => integer(ceil(log2(real(8)))),
--		widthad_b => integer(ceil(log2(real(8)))),
--		width_a => 16,
--		width_b => 16,
--		width_byteena_a => 1
--	)
--	port map (
--		clock0 => clk,
--		aclr0 => t_reset,
--		address_a => t_wr_pointer(integer(ceil(log2(real(8)))) - 1 downto 0),
--		data_a => t_avg,
--		wren_a => '0',
--		address_b => t_pointer(integer(ceil(log2(real(8)))) - 1 downto 0),
--		q_b => s_reg_b_out
--	);	

---------------------------------------------------------------------------------------------------
t_clk_process : process
begin
	t_clk <= '1';
	wait for t_clk_period/2;
	t_clk <= '0';
	wait for t_clk_period/2;
end process;

---------------------------------------------------------------------------------------------------
t_reset_process : process
begin
	--t_reset <= '0';
	--wait for t_clk_period * 3;
	t_reset <= '1';
	wait for t_clk_period/2;
	t_reset <= '0';

	wait for t_clk_period * 20;
	t_reset <= '1';
	wait for t_clk_period;
	t_reset <= '0';
	wait;
end process;
---------------------------------------------------------------------------------------------------
--data_process : process
--begin
--	wait for t_clk_period * 4;

--	t_data <= x"0001";
--	wait for t_clk_period;

--	t_data <= x"0002";
--	wait for t_clk_period;

--	t_data <= x"0003";
--	wait for t_clk_period;

--	t_data <= x"0004";
--	wait for t_clk_period;

--	t_data <= x"0005";
--	wait for t_clk_period * 6;

--	t_data <= x"0003";
--	wait for t_clk_period;

--	t_data <= x"0003";
--	wait for t_clk_period;

--	t_data <= x"0002";
--	wait for t_clk_period;

--	t_data <= x"0001";
--	wait for t_clk_period;

--	wait;
--end process ; -- a_b_process

---------------------------------------------------------------------------------------------------
rd_pointer_process : process(t_clk)
begin
	if (rising_edge(t_clk)) then
		t_pointer <= t_pointer + '1';
	end if;
end process;

---------------------------------------------------------------------------------------------------
wr_pointer_process : process(t_clk)
begin
	if (rising_edge(t_clk) and t_pointer /= "000000000") then
		t_wr_pointer <= t_wr_pointer + '1';
		reg_a_ld <= '1';
	end if;
end process;

---------------------------------------------------------------------------------------------------
end architecture ; -- behaviour