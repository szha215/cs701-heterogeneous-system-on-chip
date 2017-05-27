library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.recop_types.all;
use work.opcodes.all;
use work.HMPSoC_config.all;

-- various registers of recop
entity registers is
	 generic(
		recop_id : integer :=0
	 );
    port (
		clk : in bit_1;
		reset : in bit_1;
		dpcr: out bit_32;
		r7 : in bit_16;
		rx : in bit_16;
		ir_operand : in bit_16;
		dpcr_lsb_sel : in bit_1;
		dpcr_wr : in bit_1;
		-- environment ready and set and clear signals
		er: out bit_1;
		er_wr : in bit_1;
		er_clr : in bit_1;
		-- end of thread and set and clear signals
		eot: out bit_1;
		eot_wr : in bit_1;
		eot_clr : in bit_1;
		-- svop and write enable signal
		svop : out bit_16;
		svop_wr : in bit_1;
		-- sip souce and registered outputs
		sip_r : out bit_16;
		sip : in bit_16;
		-- sop and write enable signal
		sop : out bit_16;
		sop_wr : in bit_1;
		-- dprr, irq (dprr(1)) set and clear signals and result source and write enable signal
		--irq_wr:in bit_1;
		dprr :in bit_32;
		dprr_int :out bit_32;
		dpcr_io_wr : in bit_1;
		dispatched : in bit_1;
		dispatched_io : in bit_1;
		jop_free : in bit_1
		);
end registers;

architecture beh of registers is
  signal sip_r_int : bit_16;
  signal dpcr_io_r : bit_32;
  signal dpcr_int : bit_32;
  begin
		
	----------------------------------------------
	-- DPRR register for the dynamic case
	----------------------------------------------
	dyn_gen: if DYNAMIC = '1' and DYNAMIC_FIFO = '0' generate
	
		dpcr <= dpcr_int when jop_free = '1' else dpcr_io_r;
	
		process (clk, reset)
		begin
			if reset = '1' then
				dpcr_int <= X"00000000";
			elsif rising_edge(clk) then 
				if dpcr_wr = '1' then
					-- write to dpcr. lower byte depends on select signal
--					report "CD "&integer'image(conv_integer(unsigned(r7)))&" "&integer'image(conv_integer(unsigned(rx)));
					case dpcr_lsb_sel is
					when '0' =>
						dpcr_int <= r7 & rx;
					when '1' =>
						dpcr_int <= ir_operand & rx;
					when others =>
					end case;
					-- dpcr_int Set valid request bit
					dpcr_int(31) <= '1';
				elsif dispatched = '1' then
					-- Holds the content of the register until it is dispatched
					dpcr_int <= X"00000000";
				end if;
			end if;
		end process;
		
		----------------------------------------------
		-- DPRR/IO register for the dynamic case
		----------------------------------------------
		process (clk, reset)
		begin
			if reset = '1' then
				dpcr_io_r <= X"00000000";
			elsif rising_edge(clk) then 
				if dpcr_io_wr = '1' then
					-- write to dpcr_io_r. lower byte depends on select signal
--					report "CD "&integer'image(conv_integer(unsigned(r7)))&" "&integer'image(conv_integer(unsigned(rx)));
					case dpcr_lsb_sel is
					when '0' =>
						dpcr_io_r <= r7 & rx;
					when '1' =>
						dpcr_io_r <= ir_operand & rx;
					when others =>
					end case;
					-- Set valid request bit
					dpcr_io_r(31) <= '1';
				elsif dispatched_io = '1' then
					-- Holds the content of the register until it is dispatched
					dpcr_io_r <= X"00000000";
				end if;
			end if;
		end process;
		
	end generate;

	----------------------------------------------
	-- DPRR register for the static case
	----------------------------------------------
	static_gen: if DYNAMIC = '0' or DYNAMIC_FIFO = '1' generate
		-- dpcr
		process (clk, reset)
		begin
			if reset = '1' then
				dpcr <= X"00000000";
			elsif rising_edge(clk) then 
				if dpcr_wr = '1' then
					-- write to dpcr. lower byte depends on select signal
--					report "CD "&integer'image(conv_integer(unsigned(r7)))&" "&integer'image(conv_integer(unsigned(rx)));
					case dpcr_lsb_sel is
					when '0' =>
						dpcr <= r7 & rx;
					when '1' =>
						dpcr <= ir_operand & rx;
					when others =>
					end case;
					-- Set valid request bit
					dpcr(31) <= '1';
					-- Not required for SystemJ
					-- dpcr(6 downto 4) <= conv_std_logic_vector(recop_id,3);
				else
					-- FIFO stores the contents of the DPCR register after 1 clock cycle
					dpcr <= X"00000000";
				end if;
			end if;
		end process;
	end generate;

	
	-- er
	process (clk, reset)
	begin
		if reset = '1' then
			er <= '0';
		elsif rising_edge(clk) then 
			-- set or clear er
			if er_wr = '1' then
				er <= '1';
			elsif er_clr = '1' then
				er <= '0';
			end if;
		end if;
	end process;
	
	-- eot
	process (clk, reset)
	begin
		if reset = '1' then
			eot <= '0';
		elsif rising_edge(clk) then 
			-- set or clear eot
			if eot_wr = '1' then
				eot <= '1';
			elsif eot_clr = '1' then
				eot <= '0';
			end if;
		end if;
	end process;
	
	-- svop
	process (clk, reset)
	begin
		if reset = '1' then
			svop <= X"0000";
		elsif rising_edge(clk) then 
			if svop_wr = '1' then
				-- write Rx into SVOP upon write signal 
				svop <= rx;
			end if;
		end if;
	end process;
	
	-- sip
	process (clk, reset)
	begin
		if reset = '1' then
			sip_r_int <= X"0001";
		elsif rising_edge(clk) then 
		-- register the sip signal with the system's clock
		--	sip_r <= sip;
			sip_r_int(15 downto 1) <= (others => '0');
			sip_r_int(0) <= sip_r_int(0);
			if dispatched = '1' then
				sip_r_int(0) <= '1';
			elsif dpcr_wr = '1' then
				sip_r_int(0) <= '0';
			end if;
		end if;
	end process;
	sip_r <= sip_r_int;
	
	-- sop
	process (clk, reset)
	begin
		if reset = '1' then
			sop <= X"0000";
		elsif rising_edge(clk) then 
			if sop_wr = '1' then
				-- write Rx into SOP upon write signal 
				sop <= rx;
			end if;
		end if;
	end process;
	
	-- dprr
	process (clk, reset, dprr)
	begin
		if reset = '1' then
			dprr_int <= (others =>'0');
		elsif rising_edge(clk) then 
			dprr_int <= dprr;
		end if;
	end process;	
end beh;
