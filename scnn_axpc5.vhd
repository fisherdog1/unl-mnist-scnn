library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity scnn_axpc5 is
	generic (
			bits_in : integer := 5);
	port ( 	vec_in : in std_logic_vector(bits_in - 1 downto 0);
				asum_out : out std_logic_vector(integer(log2(real(bits_in))) downto 0) );
end scnn_axpc5;

architecture rtl of scnn_axpc5 is
begin
	--For our purposes this is just an exact parallel adder
	process (vec_in)
		variable sum : integer;
	begin
		sum := 0;
	
		for I in vec_in'range loop
			if vec_in(I) = '1' then
				sum := sum + 1;
			end if;
		end loop;
		
		asum_out <= std_logic_vector(to_unsigned(sum, asum_out'length));
	end process;
end rtl;