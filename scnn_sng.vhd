library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Converts a binary number to a stochastic stream

entity scnn_sng is
	generic (
		bits : integer := 4 );
	port (
		weight_in : in std_logic_vector(bits - 1 downto 0);
		lfsr_in : in std_logic_vector(bits - 1 downto 0);
		sn : out std_logic );
end scnn_sng;

architecture rtl of scnn_sng is
	signal lower_zeros, weight_products : std_logic_vector(bits - 1 downto 0);
begin

	lower_zeros(bits - 1) <= '1';

	Zeros: for I in bits - 2 downto 0 generate
		--w[I] wrt. ACM paper implementation
		lower_zeros(I) <= '1' when to_integer(unsigned(lfsr_in(bits - 1 downto I + 1))) = 0 else '0';
	end generate Zeros;
	
	Weights: for I in bits - 1 downto 0 generate
		weight_products(I) <= lower_zeros(I) and lfsr_in(I) and weight_in(I);
	end generate Weights;
	
	sn <= '0' when to_integer(unsigned(weight_products)) = 0 else '1';
end rtl;