library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

---------------------------------------------------------------------------------------------------
entity fake_jop is
	port(
		clk	: in std_logic;
		sw		: in std_logic_vector(15 downto 0);
		key	: in std_logic_vector(3 downto 0);

		data	: out std_logic_vector(31 downto 0);
		sw_v	: out std_logic_vector(15 downto 0)
	);
end entity fake_jop;

---------------------------------------------------------------------------------------------------
architecture behaviour of fake_jop is


type states is (IDLE,
					S_R,
					S1_0, S1_1, S1_2, S1_3, S1_4, S1_5, S1_6,
					S2_0, S2_1, S2_2, S2_3, S2_4, S2_5, S2_6, S2_7, S2_8,
					X1, X2, 
					M1, 
					A1, A2
					);

signal CS, NS	: states := IDLE;

signal s_data	: std_logic_vector(31 downto 0) := (others => '0');

signal s_en_0, s_en_1, s_en_2, s_en_3		: std_logic := '0';
signal s_en_0_old, s_en_1_old, s_en_2_old, s_en_3_old	: std_logic := '0';

---------------------------------------------------------------------------------------------------
begin

---------------------------------------------------------------------------------------------------
state_updater: process(clk)
begin
	if (rising_edge(clk)) then
		CS <= NS;
	end if;
end process state_updater;

---------------------------------------------------------------------------------------------------
state_transition_logic : process(CS, NS, s_en_0, s_en_1, s_en_2, s_en_3, sw)
begin
	case CS is	-- must cover all states
		when IDLE =>
			if (s_en_3 = '1' and sw = x"0000") then
				NS <= S_R;
			elsif (s_en_3 = '1' and sw = x"0001") then
				NS <= S1_0;
			elsif (s_en_3 = '1' and sw = x"0002") then
				NS <= S2_0;
			elsif (s_en_3 = '1' and sw = x"0003") then
				NS <= X1;
			elsif (s_en_3 = '1' and sw = x"0004") then
				NS <= M1;
			elsif (s_en_3 = '1' and sw = x"0005") then
				NS <= A1;
			elsif (s_en_3 = '1' and sw = x"0006") then
				NS <= X2;
			elsif (s_en_3 = '1' and sw = x"0007") then
				NS <= A2;
			else
				NS <= IDLE;
			end if;

		when S_R =>
			NS <= IDLE;

		when S1_0 =>
			NS <= S1_1;

		when S1_1 =>
			NS <= S1_2;

		when S1_2 =>
			NS <= S1_3;
						
		when S1_3 =>
			NS <= S1_4;
			
		when S1_4 =>
			NS <= S1_5;
						
		when S1_5 =>
			NS <= S1_6;
			
		when S1_6 =>
			NS <= IDLE;

		when S2_0 =>
			NS <= S2_1;
			
		when S2_1 =>
			NS <= S2_2;
			
		when S2_2 =>
			NS <= S2_3;
			
		when S2_3 =>
			NS <= S2_4;
			
		when S2_4 =>
			NS <= S2_5;
		
		when S2_5 =>
			NS <= S2_6;
			
		when S2_6 =>
			NS <= S2_7;
			
		when S2_7 =>
			NS <= S2_8;
			
		when S2_8 =>
			NS <= IDLE;
			
		when X1 =>
			NS <= IDLE;

		when X2 =>
			NS <= IDLE;

		when M1 =>
			NS <= IDLE;

		when A1 =>
			NS <= IDLE;

		when A2 =>
			NS <= IDLE;

		when others =>
			report "Transition: BAD STATE";

	end case;
end process state_transition_logic;

---------------------------------------------------------------------------------------------------
output_logic : process(CS)
begin
	case CS is	-- must cover all states
		when IDLE =>
			s_data <= (others => '0');

		when S_R =>
			s_data <= x"C8000000";  -- STORE CLEAR ALL

		when S1_0 =>
			s_data <= x"C8460006";  -- STORE, to 2, from 1, 6 words

		when S1_1 =>
			s_data <= x"C8010099";  -- B[1] = 0x99

		when S1_2 =>
			s_data <= x"C8020101";  -- B[2] = 0x101

		when S1_3 =>
			s_data <= x"C8030103";  -- B[3] = 0x103

		when S1_4 =>
			s_data <= x"C8040105";  -- B[4] = 0x105

		when S1_5 =>
			s_data <= x"C8050107";  -- B[5] = 0x107

		when S1_6 =>
			s_data <= x"C8060109";  -- B[6] = 0x109 C8480000

		when S2_0 =>
			s_data <= x"C8480008";  -- STORE, to 2, from 2, 8 words

		when S2_1 =>
			s_data <= x"C8000ECE";  -- A[0] = 0xECE

		when S2_2 =>
			s_data <= x"C8010111";  -- A[1] = 0xECE

		when S2_3 =>
			s_data <= x"C8020222";  -- A[2] = 0xECE

		when S2_4 =>
			s_data <= x"C8030333";  -- A[3] = 0xECE

		when S2_5 =>
			s_data <= x"C8040444";  -- A[4] = 0xECE

		when S2_6 =>
			s_data <= x"C8050555";  -- A[5] = 0xECE
	
		when S2_7 =>
			s_data <= x"C8060666";  -- A[6] = 0xECE

		when S2_8 =>
			s_data <= x"C8070777";  -- A[7] = 0xECE

		when X1 =>
			s_data <= x"C8800A00";  -- XOR A[0] to A[5], to 2, from 0

		when X2 =>
			s_data <= x"C8C40C02";  -- XOR B[2] to B[6], to 2, from 1

		when M1 =>
			s_data <= x"C9080E02";  -- MAC [2] to [7], to 2, from 2 -

		when A1 =>
			s_data <= x"C9440800";  -- AVE A, to 2, from 1, end address = 3 (L = 4)

		when A2 =>
			s_data <= x"C9801000";  -- AVE B, to 2, from 0, end address = 7 (L = 8)

		when others =>
			report "Output: BAD STATE";
			s_data <= (others => '0');
			
	end case;
end process output_logic;

---------------------------------------------------------------------------------------------------
b0 : process(clk, key(0))
begin
	if (rising_edge(clk)) then
		if (key(0) = not s_en_0_old) then
			s_en_0 <= key(0);
			s_en_0_old <= key(0);
		else
			s_en_0 <= '0';
			s_en_0_old <= s_en_0_old;
		end if;
	end if;
end process;

---------------------------------------------------------------------------------------------------
b1 : process(clk, key(1))
begin
	if (rising_edge(clk)) then
		if (key(1) = not s_en_1_old) then
			s_en_1 <= key(1);
			s_en_1_old <= key(1);
		else
			s_en_1 <= '0';
			s_en_1_old <= s_en_1_old;
		end if;
	end if;
end process;

---------------------------------------------------------------------------------------------------
b2 : process(clk, key(2))
begin
	if (rising_edge(clk)) then
		if (key(2) = not s_en_2_old) then
			s_en_2 <= key(2);
			s_en_2_old <= key(2);
		else
			s_en_2 <= '0';
			s_en_2_old <= s_en_2_old;
		end if;
	end if;
end process;

---------------------------------------------------------------------------------------------------
b3 : process(clk, key(3))
begin
	if (rising_edge(clk)) then
		if (key(3) = not s_en_3_old) then
			s_en_3 <= key(3);
			s_en_3_old <= key(3);
		else
			s_en_3 <= '0';
			s_en_3_old <= s_en_3_old;
		end if;
	end if;
end process;

---------------------------------------------------------------------------------------------------


data <= s_data;

sw_v <= sw;

---------------------------------------------------------------------------------------------------
end architecture;
