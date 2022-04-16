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
			avm_export_waitrequest          : in  std_logic                    := 'X';             -- waitrequest
			avm_export_readdata             : in  std_logic_vector(7 downto 0) := (others => 'X'); -- readdata
			avm_export_readdatavalid        : in  std_logic                    := 'X';             -- readdatavalid
			avm_export_burstcount           : out std_logic_vector(0 downto 0);                    -- burstcount
			avm_export_writedata            : out std_logic_vector(7 downto 0);                    -- writedata
			avm_export_address              : out std_logic_vector(9 downto 0);                    -- address
			avm_export_write                : out std_logic;                                       -- write
			avm_export_read                 : out std_logic;                                       -- read
			avm_export_byteenable           : out std_logic_vector(0 downto 0);                    -- byteenable
			avm_export_debugaccess          : out std_logic;                                       -- debugaccess
			clk_clk                         : in  std_logic                    := 'X';             -- clk
			reset_reset_n                   : in  std_logic                    := 'X';             -- reset_n
			vga_if_CLK                      : out std_logic;                                       -- CLK
			vga_if_HS                       : out std_logic;                                       -- HS
			vga_if_VS                       : out std_logic;                                       -- VS
			vga_if_BLANK                    : out std_logic;                                       -- BLANK
			vga_if_SYNC                     : out std_logic;                                       -- SYNC
			vga_if_R                        : out std_logic_vector(3 downto 0);                    -- R
			vga_if_G                        : out std_logic_vector(3 downto 0);                    -- G
			vga_if_B                        : out std_logic_vector(3 downto 0);                    -- B
			dma_0_read_master_address       : out std_logic_vector(4 downto 0);                    -- address
			dma_0_read_master_chipselect    : out std_logic;                                       -- chipselect
			dma_0_read_master_read_n        : out std_logic;                                       -- read_n
			dma_0_read_master_readdata      : in  std_logic_vector(7 downto 0) := (others => 'X'); -- readdata
			dma_0_read_master_readdatavalid : in  std_logic                    := 'X';             -- readdatavalid
			dma_0_read_master_waitrequest   : in  std_logic                    := 'X'              -- waitrequest
		);
	end component testbench;

	signal shiftreg : std_logic_vector(31 downto 0);
	signal avm_export_address : std_logic_vector(9 downto 0);
	signal avm_export_writedata : std_logic_vector(7 downto 0);
	signal avm_export_write : std_logic;
	
	signal sn_vec : std_logic_vector(3 downto 0);
	signal ctr : std_logic_vector(7 downto 0) := (others => '0');
	signal wordstrobe : std_logic := '0';
	signal s2b_address : std_logic_vector(4 downto 0);
	signal s2b_readdata : std_logic_Vector(7 downto 0);
	
	signal word_ready : std_logic := '0';
	signal word_wait : std_logic := '1';
	signal dma_read_n : std_logic;
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
			vga_if_B                       => VGA_B,
			avm_export_waitrequest => '0',
			avm_export_readdata => (others => '0'),
			avm_export_readdatavalid => '1',
			avm_export_address => avm_export_address,
			avm_export_writedata => avm_export_writedata,
			avm_export_write => avm_export_write,
			dma_0_read_master_address => s2b_address,
			dma_0_read_master_readdata => s2b_readdata,
			dma_0_read_master_read_n => dma_read_n,
			dma_0_read_master_readdatavalid => word_ready,
			dma_0_read_master_waitrequest => word_wait
		);
	
	lfsr: entity work.scnn_lfsr9
		port map (
			clk => MAX10_CLK1_50,
			cke => '1',
			rst => not KEY(0),
			shiftreg => shiftreg,
			prbs => open
		);
	
	buftest: entity work.scnn_b2s_buffer
		generic map (symbols => 4, bits_per_weight => 8)
		port map (
			csi_clk => MAX10_CLK1_50,
			rsi_rst => '0',
			
			avs_address => avm_export_address(2 downto 0),
			avs_writedata => avm_export_writedata,
			avs_write => avm_export_write,
			
			lfsr_in => shiftreg(11 downto 0),
			sn_vec_out => sn_vec
		);
		
		
	word_wait <= not word_ready;
	
	bufin: entity work.scnn_s2b_buffer
		generic map (symbols => 4, bits_per_counter => 8)
		port map (
			clk => MAX10_CLK1_50,
			cke => '1',
			rst => '0',
			strobe => wordstrobe,
			sn_vec_in => sn_vec,
			avs_address => (others => '0'),
			avs_readdata => s2b_readdata, --why
			avs_read => '0'
			);
			
	--wordstrobe counter
	
	process (MAX10_CLK1_50, ctr)
	begin
		if rising_edge(MAX10_CLK1_50) then
		
			if unsigned(ctr) = unsigned(to_signed(-1, ctr'length)) then
				wordstrobe <= '1';
			else
				wordstrobe <= '0';
			end if;
			
			ctr <= std_logic_vector(unsigned(ctr) + to_unsigned(1, ctr'length));
			
			if wordstrobe = '1' then
				word_ready <= '1';
			end if;
			
			if word_ready = '1' then
				--clear word_ready on successful read
				word_ready <= '0';
			end if;
		end if;
	end process;
	
	--LEDS too bright
	HEX0 <= (others => '1');
	HEX1 <= (others => '1');
	HEX2 <= (others => '1');
	HEX3 <= (others => '1');
	HEX4 <= (others => '1');
	HEX5 <= (others => '1');
	
end rtl;