library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

library work;
use work.min_ports_pkg.all;

---------------------------------------------------------------------------------------------------
entity asp_ani_combined is
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

end entity;

---------------------------------------------------------------------------------------------------
architecture behaviour of asp_ani_combined is


signal asp_valid, asp_busy, asp_res_ready : std_logic := '0';
signal d_to_asp, d_from_asp : std_logic_vector(31 downto 0) := (others => '0');


component ani
	generic(
		constant tdm_port_id		: std_logic_vector(3 downto 0) := "0010";
		constant tdm_slot_width	: positive := 4;
		constant data_width		: positive := 32;
		constant in_depth			: positive := 16;
		constant out_depth		: positive := 16;
		constant jop_cnt			: integer := 3;
		constant recop_cnt		: integer := 1;
		constant asp_id			: integer := 0
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
		constant N : positive := 8
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

ani_component : ani
	generic map(
		tdm_slot_width	=> tdm_slot_width,
		data_width		=> 32,
		in_depth			=> 16,  -- fifo depth
		out_depth		=> 16,
		jop_cnt			=> jop_cnt,
		recop_cnt 		=> recop_cnt,
		asp_id			=> asp_id
	)
	port map(
		clk		=> clk,
		reset		=> reset,
		tdm_slot	=> tdm_slot,

		d_from_noc	=> d_from_noc,
		d_to_asp		=> d_to_asp,
		asp_valid	=> asp_valid,

		asp_busy			=> asp_busy,
		asp_res_ready  => asp_res_ready,
		d_from_asp		=> d_from_asp,
		d_to_noc			=> d_to_noc
	);

asp_component : asp
	generic map(
		N => 8
	)
	port map(
		clk	=> clk,
		reset	=> reset,
		valid	=> asp_valid,
		d_in	=> d_to_asp,

		busy			=> asp_busy,
		res_ready	=> asp_res_ready,
		d_out			=> d_from_asp
	);

---------------------------------------------------------------------------------------------------

end architecture ; -- behaviour