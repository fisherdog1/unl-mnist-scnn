library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_axpc5 of tb is
	
	component scnn_b2s_buffer is
		generic (	symbols : integer := 5;
						bits_per_weight : integer := 4);
		port (	lfsr_in : in std_logic_vector(symbols + bits_per_weight - 1 downto 0);
					sn_vec_out : out std_logic_vector(symbols - 1 downto 0) );
	end component;
	
	component scnn_lfsr9 is
		port (
			clk, cke, rst : in std_logic;
			shiftreg : buffer std_logic_vector(8 downto 0);
			prbs : out std_logic );
	end component;
	
	signal clk, cke, rst, mul_out : std_logic := '0';
	signal shiftreg : std_logic_vector(8 downto 0);
	signal sn_vec_out : std_logic_vector(4 downto 0);
	signal asum_out : std_logic_vector(2 downto 0);
	
	constant clk_per : time := 10ns;
	
begin

	clk <= not clk after clk_per / 2;

	lfsr: scnn_lfsr9
		port map (clk => clk, cke => cke, rst => rst, prbs => open, shiftreg => shiftreg);
	
	dut: scnn_b2s_buffer
		port map (lfsr_in => shiftreg, sn_vec_out => sn_vec_out);
	
	--multiply test
	
	mul_out <= sn_vec_out(0) and sn_vec_out(1);
	
	process
	begin
	
		rst <= '1';
		cke <= '0';
		wait for clk_per * 2;
		
		rst <= '0';
		cke <= '1';
		
		wait for 100us;
		
	end process;
	
end tb_axpc5;