library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_lfsr9 of tb is
	signal clk, cke, prbs, rst : std_logic := '0';
	signal wordstrobe_z1, wordstrobe_z2, wordstrobe : std_logic := '0';
	
	signal count, count2 : std_logic_vector(8 downto 0);
	signal shiftreg : std_logic_vector(8 downto 0);
	
	constant clk_per : time := 200ps;
	
	component scnn_lfsr9 is
		port (
			clk, cke, rst : in std_logic;
			shiftreg : buffer std_logic_vector(8 downto 0);
			prbs : out std_logic );
		end component;
		
	component scnn_accumulator is
		generic (
			bits : integer := 9 );
		port (
			clk, up, rst, wordstrobe : in std_logic := '0';
			count : out std_logic_vector(bits - 1 downto 0) := (others => '0') );
	end component;
	
	component scnn_sng is
		generic (
			bits : integer := 4 );
		port (
			weight_in : in std_logic_vector(bits - 1 downto 0);
			lfsr_in : in std_logic_vector(bits - 1 downto 0);
			sn : out std_logic );
		end component;
		
		signal sn1, sn2 : std_logic;
begin

	clk <= not clk after clk_per / 2;

	dut: scnn_lfsr9
		port map (clk => clk, cke => cke, rst => rst, prbs => prbs, shiftreg => shiftreg);
	
	wordctr: scnn_accumulator
		port map (clk => clk, up => '1', wordstrobe => '1', rst => rst, count => count);
	
	wordstrobe_z1 <= count(8);
	
	sng1: scnn_sng
		port map (weight_in => "1000", lfsr_in => shiftreg(3 downto 0), sn => sn1);
	
	sng2: scnn_sng
		port map (weight_in => "0100", lfsr_in => shiftreg(7 downto 4), sn => sn2);
	
	stocctr1: scnn_accumulator
		port map (clk => clk, up => sn1, wordstrobe => wordstrobe, rst => wordstrobe, count => open);
		
	stocctr2: scnn_accumulator
		port map (clk => clk, up => sn2, wordstrobe => wordstrobe, rst => wordstrobe, count => open);
	
	process (clk, rst)
	begin
		if rst = '1' then
			wordstrobe_z2 <= '0';
			wordstrobe <= '0';
			
		elsif rising_edge(clk) then
			wordstrobe_z2 <= wordstrobe_z1;
			wordstrobe <= wordstrobe_z1 and not wordstrobe_z2;
			
		end if;
	end process;
	
	process
	begin
		rst <= '1';
		
		wait for clk_per * 2;
		
		rst <= '0';
		cke <= '1';
		
		wait for 1000us;
		
	end process;
	
end tb_lfsr9;