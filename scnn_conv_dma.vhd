library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity scnn_conv_dma is
	generic (
		image_width : integer := 32; --Z
		image_height : integer := 32; --V
		kernel_width : integer := 5; --X
		kernel_height : integer := 5 ); --Y
	port (
		clk, cke, rst : in std_logic;
		avm_address : out std_logic_vector();
		avm_readdata : in std_logic_vector(7 downto 0);
		avm_read : out std_logic;
		avm_waitrequest : in std_logic );
end scnn_conv_dma;

architecture rtl of scnn_conv_dma is
	
	type kernel_sc_t is array(kernel_height - 1 downto 0) of std_logic_vector(kernel_width - 1 downto 0);
	signal kernel_sc : kernel_sc_t;
	signal image_row_sc : std_logic_vector(image_width - 1 downto 0);
	type smx_out_t is array (image_width - 1 downto 0) of kernel_sc_t;
	signal smx_out_sc : smx_out_t;
	
	signal rng_taps: std_logic_vector(kernel_size + image_width - 1);
	
	signal accumulators_cke : std_logic;
	signal accumulator_stb, sn_row_axpc_vec : std_logic_vector(4 downto 0);
	
	constant kernel_size : integer := kernel_width * kernel_height;
	constant pad_bits : integer := kernel_width / 2;
	
	signal axpc_vec_padded : std_logic_vector(pad_bits + image_width + pad_bits - 1 downto 0);
	signal sn_row_axpc_vec : std_logic_vector(image_width - 1 downto 0);
begin

	process (clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
			elsif cke = '1' then
			end if;
		end if;
	end process;

	
	--Generate SNG signals for every kernel pixel
	kernel_rows: for Y in kernel_height - 1 downto 0 generate
		entity work.scnn_b2s_buffer
			generic map (symbols => kernel_width, bits_per_weight => 8)
			port map (
				csi_clk => clk,
				rsi_rst => rst,
				
				avs_address => ,
				avs_writedata => ,
				avs_write => ,
				
				lfsr_in => rng_taps((Y+1)*kernel_width - 1 downto Y*kernel_width),
				sn_vec_out => kernel_sc(Y) );
	end generate kernel_rows;
	
	--Generate SNG signals for every pixel in one row of image input
	image_row_b2s: entity work.scnn_b2s_buffer
		generic map (symbols => image_width, bits_per_weight => 8)
		port map (
			csi_clk => clk,
			rsi_rst => rst,
			
			avs_address => ,
			avs_writedata => ,
			avs_write => ,
			
			lfsr_in => rng_taps(kernel_size + image_width - 1 downto kernel_size), --Dont use same LFSR taps as any of the kernel SNGs
			sn_vec_out => image_row_sc );
	
	--Generate stochastic multiplication matrix
	kernel_row_smx: for Y in kernel_height - 1 downto 0 generate
		image_col_smx: for Z in image_width - 1 downto 0 generate
			kernel_col_smx: for X in kernel_width - 1 downto 0 generate
				smx_out_sc(Z)(Y)(X) <= image_row_sc(Z) xnor kernel_sc(Y)(X);
			end generate kernel_col_smx;
		end generate image_col_smx;
	end generate kernel_row_smx;
	
	--TODO this is incomplete, need to pad signals at image edges
	image_row_axpc: for Z in image_width-1 downto 0 generate
		kernel_row_axpc: for Y in kernel_height downto 0 generate
			entity work.scnn_axpc5
				generic map (bits_in => kernel_width)
				port map (
					vec_in => axpc_vec_padded(Z + kernel_width - 1 downto Z),
					asum_out => sn_row_axpc_vec(Z));
		end generate kernel_row_axpc;
	end generate image_row_axpc;
	
	s2b_accumulators: for I in 4 downto 0 generate
		entity work.scnn_s2b_buffer
			generic map (symbols => 32, bits_per_counter => 8)
			port map (
				clk => clk,
				cke => accumulators_cke,
				rst => rst,
				strobe => accumulator_stb(I),
				sn_vec_in => sn_row_axpc_vec(I),
				avs_address => (others => '0'),
				avs_readdata => s2b_readdata, --why
				avs_read => '0' );
	end generate s2b_accumulators;
end rtl;