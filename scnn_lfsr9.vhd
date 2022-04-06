library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scnn_lfsr9 is
	port (
		clk, cke, rst : in std_logic;
		prbs : out std_logic );
end scnn_lfsr9;

architecture rtl of scnn_lfsr9 is
	signal shiftreg : std_logic_vector(8 downto 0);
begin

	--pseudo random bit sequence out
	prbs <= shiftreg(0);
	
	process (clk, cke, rst)
	begin
		if rst = '1' then
			--0 is not a valid state for this lfsr
			--typically an LFSR would be initialized with 1 (000000001)
			--this is not done due to reset limitations in most fpgas
			shiftreg <= (others => '1');
			
		elsif cke = '1' and rising_edge(clk) then
			--shift bits right
			shiftreg <= (shiftreg(5) xor shiftreg(0)) & shiftreg(8 downto 1);
			
		end if;
	end process;
end rtl;