library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

---------------------------------------------------------------------------------------------------
entity test_ani is
end test_ani;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_ani is
-- type, signal declarations

constant t_clk_period : time := 20 ns;
constant t_tdm_slot_width : positive := 2;

signal t_clk, t_reset, t_asp_valid, t_asp_busy, t_asp_res_ready : std_logic := '0';
signal t_d_from_noc, t_d_to_asp, t_d_from_asp, t_d_to_noc : std_logic_vector(31 downto 0) := (others => '0');
signal t_tdm_slot : std_logic_vector(t_tdm_slot_width - 1 downto 0) := (others => '0');


---------------------------------------------------------------------------------------------------
-- component declarations
component ani
	generic(
		constant tdm_slot_width	: positive := 4;
		constant data_width		: positive := 32;
		constant in_depth			: positive := 16;
		constant out_depth		: positive := 16
	);
	port(
		-- control inputs
		clk		: in std_logic;
		reset		: in std_logic;
		tdm_slot : in std_logic_vector(tdm_slot_width - 1 downto 0);

		-- incoming from NoC to ASP
		d_from_noc	: in std_logic_vector(data_width - 1 downto 0);
		d_to_asp		: out std_logic_vector(data_width - 1 downto 0);
		asp_valid	: out std_logic;

		-- outgoing from ASP to NoC
		asp_busy			: in std_logic;
		asp_res_ready	: in std_logic;
		d_from_asp		: in std_logic_vector(data_width - 1 downto 0);
		d_to_noc			: out std_logic_vector(data_width - 1 downto 0)
	);
	end component;

component asp is
	generic(
		constant N : positive := 8;
		constant L : positive := 4
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		valid		: in std_logic;
		d_in		: in std_logic_vector(31 downto 0);

		busy			: out std_logic;
		res_ready	: out std_logic;
		d_out			: out std_logic_vector(31 downto 0)
	);
end component asp;

---------------------------------------------------------------------------------------------------
begin
--- component wiring

t_ani : ani
	generic map(
		tdm_slot_width	=> t_tdm_slot_width,
		data_width		=> 32,
		in_depth			=> 16,
		out_depth		=> 16
	)
	port map(
		clk		=> t_clk,
		reset		=> t_reset,
		tdm_slot	=> t_tdm_slot,

		d_from_noc	=> t_d_from_noc,
		d_to_asp		=> t_d_to_asp,
		asp_valid	=> t_asp_valid,

		asp_busy			=> t_asp_busy,
		asp_res_ready  => t_asp_res_ready,
		d_from_asp		=> t_d_from_asp,
		d_to_noc			=> t_d_to_noc
	);

t_asp : asp
	generic map(
		N => 8,
		L => 4
	)
	port map(
		clk	=> t_clk,
		reset	=> t_reset,
		valid	=> t_asp_valid,
		d_in	=> t_d_to_asp,

		busy			=> t_asp_busy,
		res_ready	=> t_asp_res_ready,
		d_out			=> t_d_from_asp
	);

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
	t_reset <= '0';
	wait for t_clk_period * 3;
	t_reset <= '1';
	wait for t_clk_period;
	t_reset <= '0';
	wait;
end process;

---------------------------------------------------------------------------------------------------
t_tdm_slot_process : process
begin
	wait for t_clk_period;
	t_tdm_slot <= t_tdm_slot + "01";
end process;

---------------------------------------------------------------------------------------------------
t_d_from_noc_process : process
begin
	wait for t_clk_period * 6;

	t_d_from_noc <= x"C8460006";  -- STORE
	wait for t_clk_period;
	t_d_from_noc <= (others => '0');
	wait for t_clk_period * 4;

	t_d_from_noc <= x"C8010099";
	wait for t_clk_period;
	t_d_from_noc <= (others => '0');
	wait for t_clk_period * 4;

	t_d_from_noc <= x"F3333333";
	wait for t_clk_period;
	t_d_from_noc <= x"F4444444";
	wait for t_clk_period;
	t_d_from_noc <= x"F5555555";
	wait for t_clk_period;

	t_d_from_noc <= (others => '0');
	wait;

end process;
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
-- combinational logic



end architecture;