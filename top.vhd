library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port(
		MAX10_CLK1_50	: in std_logic;
		KEY	: in std_logic_vector(1 downto 0);
		SW		:in std_logic_vector(9 downto 0);
		LEDR	:out	std_logic_vector(9 downto 0);
		HEX0	:out std_logic_vector(7 downto 0);
		HEX1	:out std_logic_vector(7 downto 0);
		HEX2	:out std_logic_vector(7 downto 0);
		HEX3	:out std_logic_vector(7 downto 0);
		HEX4	:out std_logic_vector(7 downto 0);
		HEX5	:out std_logic_vector(7 downto 0);
		VGA_B : out std_logic_vector(3 downto 0);
		VGA_G : out std_logic_vector(3 downto 0);
		VGA_HS : out std_logic;
		VGA_R : out std_logic_vector(3 downto 0);
		VGA_VS : out std_logic );
end top;

architecture rtl of top is

	component testbench is
		port (
			clk_clk       : in  std_logic                    := 'X'; -- clk
			reset_reset_n : in  std_logic                    := 'X'; -- reset_n
			vga_if_CLK    : out std_logic;                           -- CLK
			vga_if_HS     : out std_logic;                           -- HS
			vga_if_VS     : out std_logic;                           -- VS
			vga_if_BLANK  : out std_logic;                           -- BLANK
			vga_if_SYNC   : out std_logic;                           -- SYNC
			vga_if_R      : out std_logic_vector(3 downto 0);        -- R
			vga_if_G      : out std_logic_vector(3 downto 0);        -- G
			vga_if_B      : out std_logic_vector(3 downto 0)         -- B
		);
	end component testbench;

begin
	
	vga_testbench : component testbench
		port map (
			clk_clk                        => MAX10_CLK1_50,                        
			reset_reset_n                  => '1',                 
			vga_if_CLK                     => open,                     
			vga_if_HS                      => VGA_HS,                      
			vga_if_VS                      => VGA_VS,                      
			vga_if_BLANK                   => open,
			vga_if_SYNC                    => open,                    
			vga_if_R                       => VGA_R,                       
			vga_if_G                       => VGA_G,                       
			vga_if_B                       => VGA_B                        
		);
	
	--LEDS too bright
	HEX0 <= (others => '1');
	HEX1 <= (others => '1');
	HEX2 <= (others => '1');
	HEX3 <= (others => '1');
	HEX4 <= (others => '1');
	HEX5 <= (others => '1');
	
end rtl;