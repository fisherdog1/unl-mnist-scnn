library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity scnn_s2b_buffer is
	generic (	symbols : integer := 5;
					bits_per_counter : integer := 4 );
	port (	clk, cke, rst, strobe : in std_logic;
	
				avs_address : in std_logic_vector(integer(log2(real(symbols - 1))) downto 0);
				avs_readdata : out std_logic_vector(7 downto 0);
				avs_read : in std_logic;
	
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
	
	type buf_symbols_t is array(0 to symbols - 1) of std_logic_vector(bits_per_counter - 1 downto 0);
	signal buf : buf_symbols_t := (others => (others => '0')); --Temporary 
	
begin

	up <= sn_vec_in when cke = '1' else (others => '0');

	--count => symbols_out( ((I+1)*bits_per_counter) - 1 downto I*bits_per_counter)
	
	Ctrs: for I in symbols - 1 downto 0 generate
		Ctr: component scnn_accumulator
			generic map (bits => bits_per_counter)
			port map (clk => clk, up => up(I), rst => rst, wordstrobe => strobe, count => buf(I));
	end generate Ctrs;

	process (avs_address, avs_read, buf)
		variable bank_index : integer;
	begin
		bank_index := to_integer(unsigned(avs_address));
		
		--Temporary, address decoding would be preferable
		avs_readdata <= buf(bank_index);
	end process;
	
end rtl;