library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity test_recop is
end entity test_recop;


architecture behaviour of test_recop is

constant clk_period : time := 20 ns;
signal t_clk : std_logic;

signal t_ER_in, t_EOT_out : std_logic := '0';
signal t_DPRR_in,t_DPCR_out : std_logic_vector(31 downto 0) := (others => '0');
signal t_SIP_in,t_SVOP_out,t_SOP_out : std_logic_vector(15 downto 0) := (others => '0');





component recop is
-- generic and port declration here
generic(
	constant reg_width : positive := 16
);


port(	clk				: in std_logic;
		ER_in			: in std_logic;
		DPRR_in			: in std_logic_vector(31 downto 0);
		SIP_in			: in std_logic_vector(reg_width - 1 downto 0);

		EOT_out			: out std_logic;
		DPCR_out		: out std_logic_vector(31 downto 0);
		SVOP_out		: out std_logic_vector(15 downto 0);
		SOP_out			: out std_logic_vector(15 downto 0)
	);
end component recop;
begin 

t_recop : recop
	generic map(
		reg_width => 16
	)
	port map(
		clk => t_clk,
		ER_in => t_ER_in,
		DPRR_in => t_DPRR_in,
		SIP_in => t_SIP_in,

		EOT_out => t_EOT_out,
		DPCR_out => t_DPCR_out,
		SVOP_out => t_SVOP_out,
		SOP_out => t_SOP_out
	);

clk_proc : process
begin 
	t_clk <= '1';
	wait for clk_period;
	t_clk <= '0';
	wait for clk_period;

end process clk_proc;



end architecture;

