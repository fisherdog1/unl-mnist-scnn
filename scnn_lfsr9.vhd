library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scnn_lfsr9 is
	port (
		clk, cke, rst : in std_logic;
		shiftreg : buffer std_logic_vector(31 downto 0) := (others => '1');
		prbs : out std_logic );
end scnn_lfsr9;

architecture rtl of scnn_lfsr9 is
begin

	--pseudo random bit sequence out
	prbs <= shiftreg(shiftreg'length - 1);
	
	process (clk, cke, rst)
	begin
		if rst = '1' then
			--0 is not a valid state for this lfsr
			--typically an LFSR would be initialized with 1 (000000001)
			--this is not done due to reset limitations in most fpgas
			shiftreg <= (others => '1');
			
		elsif cke = '1' and rising_edge(clk) then
			--shift bits right
			shiftreg <= shiftreg(shiftreg'length - 2 downto 0) & (shiftreg(1) xor shiftreg(5) xor shiftreg(6) xor shiftreg(31));
			
		end if;
	end process;
end rtl;