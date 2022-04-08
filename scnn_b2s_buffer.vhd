library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scnn_b2s_buffer is
	generic (	symbols : integer := 5;
					bits_per_weight : integer := 4 );
	port (	lfsr_in : in std_logic_vector(symbols + bits_per_weight - 1 downto 0);
				sn_vec_out : out std_logic_vector(symbols - 1 downto 0) );
end scnn_b2s_buffer; 

architecture rtl of scnn_b2s_buffer is

	component scnn_sng is
		generic (
			bits : integer := 4 );
		port (
			weight_in : in std_logic_vector(bits - 1 downto 0);
			lfsr_in : in std_logic_vector(bits - 1 downto 0);
			sn : out std_logic );
	end component;

	type buf_symbols_t is array(0 to symbols - 1) of std_logic_vector(bits_per_weight - 1 downto 0);
	signal buf : buf_symbols_t := (others => (9 => '1', others => '0')); --Temporary
begin

	Sngs: for I in buf'range generate
		Sng: component scnn_sng
			generic map (bits => bits_per_weight)
			port map (weight_in => buf(I), lfsr_in => lfsr_in((I + bits_per_weight - 1) downto I), sn => sn_vec_out(I));
	end generate Sngs;
	
end rtl;