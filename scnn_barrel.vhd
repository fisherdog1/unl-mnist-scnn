library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity scnn_barrel is
	generic (
		bits_per_tap : integer := 1;
		taps : integer := 4 );
	port (
		vec_in : in std_logic_vector(taps*bits_per_tap - 1 downto 0);
		vec_out : out std_logic_vector(taps*bits_per_tap - 1 downto 0);
		sel : in std_logic_vector(integer(log2(real(taps - 1))) downto 0) );
end scnn_barrel;

architecture rtl of scnn_barrel is
begin
	process (vec_in, sel)
	begin
		Shifts: for I in taps'length - 1 downto 0 loop
			variable sel_int : integer;
		begin
			sel_int := to_integer(unsigned(sel) + to_unsigned(I, sel'length));
			vec_out((I+1)*bits_per_tap - 1 downto I*bits_per_tap) <= vec_in((sel_int+1)*bits_per_tap - 1 downto sel_int*bits_per_tap);
		end loop Shifts;
	end process;
end rtl;