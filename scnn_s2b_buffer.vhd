library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scnn_s2b_buffer is
	generic (	symbols : integer := 5;
					bits_per_counter : integer := 4 );
	port (	clk, cke, rst, strobe : in std_logic;
				sn_vec_in : in std_logic_vector(symbols - 1 downto 0);
				symbols_out : out std_logic_vector(symbols * bits_per_counter - 1 downto 0) );
end scnn_s2b_buffer;

architecture rtl of scnn_s2b_buffer is

	component scnn_accumulator is
		generic (
			bits : integer := 9 );
		port (
			clk, up, rst, wordstrobe : in std_logic := '0';
			count : out std_logic_vector(bits - 1 downto 0) := (others => '0') );
	end component;

	signal up : std_logic_vector(symbols - 1 downto 0);
	
begin

	up <= sn_vec_in when cke = '1' else (others => '0');

	Ctrs: for I in symbols - 1 downto 0 generate
		Ctr: component scnn_accumulator
			generic map (bits => bits_per_counter)
			port map (clk => clk, up => up(I), rst => rst, wordstrobe => strobe, count => symbols_out( ((I+1)*bits_per_counter) - 1 downto I*bits_per_counter));
	end generate Ctrs;

end rtl;