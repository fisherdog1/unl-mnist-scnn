library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scnn_accumulator is
	generic (
		bits : integer := 9 );
	port (
		clk, up, rst, wordstrobe : in std_logic := '0';
		count : out std_logic_vector(bits - 1 downto 0) := (others => '0') );
end scnn_accumulator;

architecture rtl of scnn_accumulator is
	signal count_internal : std_logic_vector(count'range) := (others => '0');
begin
	process (clk, up, wordstrobe)
	begin			
		if rising_edge(clk) then
			if up = '1' then
				count_internal <= std_logic_vector(unsigned(count_internal) + to_unsigned(1, count_internal'length));
			end if;
			
			if wordstrobe = '1' then
				count <= count_internal;
			end if;
			
			if rst = '1' then
				count_internal <= (others => '0');
			end if;
		end if;
	end process;
end rtl;