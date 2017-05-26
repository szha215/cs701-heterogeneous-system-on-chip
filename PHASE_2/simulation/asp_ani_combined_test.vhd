library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

---------------------------------------------------------------------------------------------------
entity test_asp_ani_combined is
end test_asp_ani_combined;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_asp_ani_combined is
-- type, signal declarations

constant t_clk_period : time := 20 ns;
constant t_tdm_slot_width : positive := 4;

signal t_clk, t_reset  : std_logic := '0';
signal t_d_from_noc, t_d_to_noc : std_logic_vector(31 downto 0) := (others => '0');
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

component asp_ani_combined is
	generic(
		constant tdm_slot_width	: positive := 4;
		constant jop_cnt			: integer := 3;
		constant recop_cnt		: integer := 1;
		constant asp_id			: integer := 0
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		tdm_slot : in std_logic_vector(tdm_slot_width - 1 downto 0);

		d_from_noc	: in std_logic_vector(31 downto 0);
		d_to_noc		: out std_logic_vector(31 downto 0)
	);

end component;

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

t_asp_ani_combined : asp_ani_combined
	generic map(
		tdm_slot_width	=> t_tdm_slot_width,
		jop_cnt			=> 3,
		recop_cnt 		=> 1,
		asp_id			=> 0
	)
	port map(
		clk		=> t_clk,
		reset		=> t_reset,
		tdm_slot	=> t_tdm_slot,

		d_from_noc	=> t_d_from_noc,
		d_to_noc		=> t_d_to_noc
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