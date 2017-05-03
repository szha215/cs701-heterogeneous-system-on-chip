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
constant t_tdm_slot_width : positive := 4;

signal t_clk, t_reset, t_asp_valid, t_asp_busy, t_asp_res_ready : std_logic := '0';
signal t_d_from_noc, t_d_to_asp, t_d_from_asp, t_d_to_noc : std_logic_vector(31 downto 0) := (others => '0');
signal t_tdm_slot : std_logic_vector(t_tdm_slot_width - 1 downto 0) := (others => '0');

signal t_key	: std_logic_vector(3 downto 0) := (others => '0');
signal t_sw		: std_logic_vector(15 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declarations
component fake_tdm_counter is
	generic(
		constant tdm_slot_width	: positive := 4
	);
	port(
		clk	: in std_logic;

		tdm_slot	: out std_logic_vector(tdm_slot_width - 1 downto 0)
	);
end component;

component fake_jop is
	port(
		clk	: in std_logic;
		sw		: in std_logic_vector(15 downto 0);
		key	: in std_logic_vector(3 downto 0);

		data	: out std_logic_vector(31 downto 0);
		sw_v	: out std_logic_vector(15 downto 0)
	);
end component;

component ani
	generic(
		constant tdm_port_id		: std_logic_vector(3 downto 0) := "0010";
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

fake_tdm_slot : fake_tdm_counter
	generic map(
		tdm_slot_width	=> t_tdm_slot_width
	)
	port map(
		clk		=> t_clk,
		tdm_slot	=> t_tdm_slot
	);

fake_jop_1	: fake_jop
	port map(
		clk	=> t_clk,
		sw		=> t_sw,
		key	=> t_key,

		data	=> t_d_from_noc
	);

t_ani : ani
	generic map(
		tdm_port_id		=> "0010",
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
		N => 512,
		L => 8
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
--t_tdm_slot_process : process
--begin
--	wait for t_clk_period;
--	t_tdm_slot <= t_tdm_slot + '1';
--end process;

---------------------------------------------------------------------------------------------------
--t_d_from_noc_process : process
--begin
--	wait for t_clk_period * 6;

--	t_d_from_noc <= x"C8460006";  -- STORE
--	wait for t_clk_period;
--	t_d_from_noc <= (others => '0');
--	wait for t_clk_period * 4;

--	t_d_from_noc <= x"C8010099";
--	wait for t_clk_period;
--	t_d_from_noc <= (others => '0');
--	wait for t_clk_period * 4;

--	t_d_from_noc <= x"C8020101";
--	wait for t_clk_period;
--	t_d_from_noc <= x"C8030103";
--	wait for t_clk_period;
--	t_d_from_noc <= x"C8040105";
--	wait for t_clk_period;
--	t_d_from_noc <= x"C8050107";
--	wait for t_clk_period;
--	t_d_from_noc <= x"C8060109";
--	wait for t_clk_period;
--	--t_d_from_noc <= x"C8070112";
--	--wait for t_clk_period;

--	t_d_from_noc <= (others => '0');
--	wait;

--end process;
---------------------------------------------------------------------------------------------------
t_b_gen : process
begin
	wait for t_clk_period * 6;

	t_sw <= x"0001";  -- STORE B[1] to B[6]
	t_key <= "1000";
	wait for t_clk_period * 12;
	t_key <= "0000";
	wait for t_clk_period * 4;

	t_sw <= x"0006";  -- XOR B[2] to B[6]
	t_key <= "1000";
	wait for t_clk_period * 10;
	t_key <= "0000";
	wait for t_clk_period * 20;

	t_sw <= x"0002";  -- STORE A[0] to A[7]
	t_key <= "1000";
	wait for t_clk_period * 10;
	t_key <= "0000";
	wait for t_clk_period * 10;

	t_sw <= x"0004";  -- MAC [2] to [7]
	t_key <= "1000";
	wait for t_clk_period * 10;
	t_key <= "0000";
	wait for t_clk_period * 10;

	t_sw <= x"0003";  -- XOR A[0] to A[5]
	t_key <= "1000";
	wait for t_clk_period * 10;
	t_key <= "0000";
	wait for t_clk_period * 10;

	t_sw <= x"0005";  -- AVE A
	t_key <= "1000";
	wait for t_clk_period * 10;
	t_key <= "0000";
	wait for t_clk_period * 10;

	t_sw <= x"0007";  -- AVE B
	t_key <= "1000";
	wait for t_clk_period * 10;
	t_key <= "0000";
	wait for t_clk_period * 10;

	--t_sw <= x"0000";  -- STORE RESET
	--t_key <= "1000";
	--wait for t_clk_period * 10;
	--t_key <= "0000";
	--wait for t_clk_period * 2;

	wait;

end process;

---------------------------------------------------------------------------------------------------
-- combinational logic



end architecture;