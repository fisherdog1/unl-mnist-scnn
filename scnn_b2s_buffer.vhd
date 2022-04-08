library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity scnn_b2s_buffer is
	generic (	symbols : integer := 5;
					bits_per_weight : integer := 4 );
	port (	avs_address : in std_logic_vector(integer(log2(real(symbols - 1))) downto 0);
				avs_writedata : in std_logic_vector(7 downto 0);
				avs_write : in std_logic;
				
				csi_clk : in std_logic;
				rsi_rst : in std_logic;
				
				lfsr_in : in std_logic_vector(symbols + bits_per_weight - 1 downto 0);
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
	signal buf : buf_symbols_t := (others => (others => '0')); --Temporary
begin

	process (avs_address, avs_writedata, avs_write)
		variable bank_index : integer;
	begin
		bank_index := to_integer(unsigned(avs_address));
		
		if rsi_rst = '1' then
			buf <= (others => (others => '0'));
			
		elsif rising_edge(csi_clk) and avs_write = '1' then
			--This only really works for bits_per_weight = 8, need address decoding
			buf(bank_index) <= avs_writedata;
			
		end if;
	end process;


	Sngs: for I in buf'range generate
		Sng: component scnn_sng
			generic map (bits => bits_per_weight)
			port map (weight_in => buf(I), lfsr_in => lfsr_in((I + bits_per_weight - 1) downto I), sn => sn_vec_out(I));
	end generate Sngs;
	
end rtl;