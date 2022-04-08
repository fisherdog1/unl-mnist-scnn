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
			shiftreg : buffer std_logic_vector(11 downto 0) := (others => '1');
			prbs : out std_logic );
	end component;
	
	component scnn_s2b_buffer is
		generic (	symbols : integer := 5;
						bits_per_counter : integer := 4 );
		port (	clk, cke, rst, strobe : in std_logic;
					sn_vec_in : in std_logic_vector(symbols - 1 downto 0);
					symbols_out : out std_logic_vector(symbols * bits_per_counter - 1 downto 0) );
	end component;
	
	signal clk, cke, rst, strobe : std_logic := '0';
	signal shiftreg : std_logic_vector(11 downto 0);
	signal sn_vec_out : std_logic_vector(1 downto 0);
	signal symbols : std_logic_vector(19 downto 0);
	
	constant clk_per : time := 10ns;
	
begin

	clk <= not clk after clk_per / 2;
	cke <= not rst;

	lfsr: scnn_lfsr9
		port map (clk => clk, cke => '1', rst => '0', prbs => open, shiftreg => shiftreg);
	
	dut: scnn_b2s_buffer
		generic map (symbols => 2, bits_per_weight => 10)
		port map (lfsr_in => shiftreg, sn_vec_out => sn_vec_out);
	
	s2b: scnn_s2b_buffer
		generic map (symbols => 2, bits_per_counter => 10)
		port map (clk => clk, cke => cke, rst => rst, strobe => strobe, sn_vec_in => sn_vec_out, symbols_out => symbols);
	
	process
	begin
	
		rst <= '1';
		wait for clk_per * 9;
		
		rst <= '0';
		
		wait for clk_per*1024;
		strobe <= '1';
		wait for clk_per;
		strobe <= '0';
		
		wait for clk_per*2;
		
	end process;
	
end tb_axpc5;