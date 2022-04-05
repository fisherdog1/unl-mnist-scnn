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
begin
	
	--Clasic test circuit
	LEDR(0) <= SW(0);
	
end rtl;