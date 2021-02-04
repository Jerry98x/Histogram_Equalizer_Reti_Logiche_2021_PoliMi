
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_tb is
end project_tb;

architecture projecttb of project_tb is
constant c_CLOCK_PERIOD         : time := 15 ns;
signal   tb_done                : std_logic;
signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst                 : std_logic := '0';
signal   tb_start               : std_logic := '0';
signal   tb_clk                 : std_logic := '0';
signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);
signal   enable_wire            : std_logic;
signal   mem_we                 : std_logic;

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);


signal RAM: ram_type := (
			0 => std_logic_vector(to_unsigned(32, 8)),
			1 => std_logic_vector(to_unsigned(3, 8)),
			2 => std_logic_vector(to_unsigned(174, 8)),
			3 => std_logic_vector(to_unsigned(174, 8)),
			4 => std_logic_vector(to_unsigned(174, 8)),
			5 => std_logic_vector(to_unsigned(174, 8)),
			6 => std_logic_vector(to_unsigned(174, 8)),
			7 => std_logic_vector(to_unsigned(174, 8)),
			8 => std_logic_vector(to_unsigned(174, 8)),
			9 => std_logic_vector(to_unsigned(174, 8)),
			10 => std_logic_vector(to_unsigned(174, 8)),
			11 => std_logic_vector(to_unsigned(174, 8)),
			12 => std_logic_vector(to_unsigned(174, 8)),
			13 => std_logic_vector(to_unsigned(174, 8)),
			14 => std_logic_vector(to_unsigned(174, 8)),
			15 => std_logic_vector(to_unsigned(174, 8)),
			16 => std_logic_vector(to_unsigned(174, 8)),
			17 => std_logic_vector(to_unsigned(174, 8)),
			18 => std_logic_vector(to_unsigned(174, 8)),
			19 => std_logic_vector(to_unsigned(174, 8)),
			20 => std_logic_vector(to_unsigned(174, 8)),
			21 => std_logic_vector(to_unsigned(174, 8)),
			22 => std_logic_vector(to_unsigned(174, 8)),
			23 => std_logic_vector(to_unsigned(174, 8)),
			24 => std_logic_vector(to_unsigned(174, 8)),
			25 => std_logic_vector(to_unsigned(174, 8)),
			26 => std_logic_vector(to_unsigned(174, 8)),
			27 => std_logic_vector(to_unsigned(174, 8)),
			28 => std_logic_vector(to_unsigned(174, 8)),
			29 => std_logic_vector(to_unsigned(174, 8)),
			30 => std_logic_vector(to_unsigned(174, 8)),
			31 => std_logic_vector(to_unsigned(174, 8)),
			32 => std_logic_vector(to_unsigned(174, 8)),
			33 => std_logic_vector(to_unsigned(174, 8)),
			34 => std_logic_vector(to_unsigned(174, 8)),
			35 => std_logic_vector(to_unsigned(174, 8)),
			36 => std_logic_vector(to_unsigned(174, 8)),
			37 => std_logic_vector(to_unsigned(174, 8)),
			38 => std_logic_vector(to_unsigned(174, 8)),
			39 => std_logic_vector(to_unsigned(174, 8)),
			40 => std_logic_vector(to_unsigned(174, 8)),
			41 => std_logic_vector(to_unsigned(174, 8)),
			42 => std_logic_vector(to_unsigned(174, 8)),
			43 => std_logic_vector(to_unsigned(174, 8)),
			44 => std_logic_vector(to_unsigned(174, 8)),
			45 => std_logic_vector(to_unsigned(174, 8)),
			46 => std_logic_vector(to_unsigned(174, 8)),
			47 => std_logic_vector(to_unsigned(174, 8)),
			48 => std_logic_vector(to_unsigned(174, 8)),
			49 => std_logic_vector(to_unsigned(174, 8)),
			50 => std_logic_vector(to_unsigned(174, 8)),
			51 => std_logic_vector(to_unsigned(174, 8)),
			52 => std_logic_vector(to_unsigned(174, 8)),
			53 => std_logic_vector(to_unsigned(174, 8)),
			54 => std_logic_vector(to_unsigned(174, 8)),
			55 => std_logic_vector(to_unsigned(174, 8)),
			56 => std_logic_vector(to_unsigned(174, 8)),
			57 => std_logic_vector(to_unsigned(174, 8)),
			58 => std_logic_vector(to_unsigned(174, 8)),
			59 => std_logic_vector(to_unsigned(174, 8)),
			60 => std_logic_vector(to_unsigned(174, 8)),
			61 => std_logic_vector(to_unsigned(174, 8)),
			62 => std_logic_vector(to_unsigned(174, 8)),
			63 => std_logic_vector(to_unsigned(174, 8)),
			64 => std_logic_vector(to_unsigned(174, 8)),
			65 => std_logic_vector(to_unsigned(174, 8)),
			66 => std_logic_vector(to_unsigned(174, 8)),
			67 => std_logic_vector(to_unsigned(174, 8)),
			68 => std_logic_vector(to_unsigned(174, 8)),
			69 => std_logic_vector(to_unsigned(174, 8)),
			70 => std_logic_vector(to_unsigned(174, 8)),
			71 => std_logic_vector(to_unsigned(174, 8)),
			72 => std_logic_vector(to_unsigned(174, 8)),
			73 => std_logic_vector(to_unsigned(174, 8)),
			74 => std_logic_vector(to_unsigned(174, 8)),
			75 => std_logic_vector(to_unsigned(174, 8)),
			76 => std_logic_vector(to_unsigned(174, 8)),
			77 => std_logic_vector(to_unsigned(174, 8)),
			78 => std_logic_vector(to_unsigned(174, 8)),
			79 => std_logic_vector(to_unsigned(174, 8)),
			80 => std_logic_vector(to_unsigned(174, 8)),
			81 => std_logic_vector(to_unsigned(174, 8)),
			82 => std_logic_vector(to_unsigned(174, 8)),
			83 => std_logic_vector(to_unsigned(174, 8)),
			84 => std_logic_vector(to_unsigned(174, 8)),
			85 => std_logic_vector(to_unsigned(174, 8)),
			86 => std_logic_vector(to_unsigned(174, 8)),
			87 => std_logic_vector(to_unsigned(174, 8)),
			88 => std_logic_vector(to_unsigned(174, 8)),
			89 => std_logic_vector(to_unsigned(174, 8)),
			90 => std_logic_vector(to_unsigned(174, 8)),
			91 => std_logic_vector(to_unsigned(174, 8)),
			92 => std_logic_vector(to_unsigned(174, 8)),
			93 => std_logic_vector(to_unsigned(174, 8)),
			94 => std_logic_vector(to_unsigned(174, 8)),
			95 => std_logic_vector(to_unsigned(174, 8)),
			96 => std_logic_vector(to_unsigned(174, 8)),
			97 => std_logic_vector(to_unsigned(174, 8)),
			others => (others => '0'));
                         

component project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_rst         : in  std_logic;
      i_start       : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end component project_reti_logiche;


begin
UUT: project_reti_logiche
port map (
          i_clk      	=> tb_clk,
          i_rst      	=> tb_rst,
          i_start       => tb_start,
          i_data    	=> mem_o_data,
          o_address  	=> mem_address,
          o_done      	=> tb_done,
          o_en   	=> enable_wire,
          o_we 		=> mem_we,
          o_data    	=> mem_i_data
          );

p_CLK_GEN : process is
begin
    wait for c_CLOCK_PERIOD/2;
    tb_clk <= not tb_clk;
end process p_CLK_GEN;


MEM : process(tb_clk)
begin
    if tb_clk'event and tb_clk = '1' then
        if enable_wire = '1' then
            if mem_we = '1' then
                RAM(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM(conv_integer(mem_address)) after 1 ns;
            end if;
        end if;
    end if;
end process;


test : process is
begin 
    wait for 100 ns;
    wait for c_CLOCK_PERIOD;
    tb_rst <= '1';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_rst <= '0';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;

	assert RAM(98) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(98))))  severity failure;
	assert RAM(99) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(99))))  severity failure;
	assert RAM(100) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(100))))  severity failure;
	assert RAM(101) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(101))))  severity failure;
	assert RAM(102) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(102))))  severity failure;
	assert RAM(103) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(103))))  severity failure;
	assert RAM(104) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(104))))  severity failure;
	assert RAM(105) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(105))))  severity failure;
	assert RAM(106) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(106))))  severity failure;
	assert RAM(107) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(107))))  severity failure;
	assert RAM(108) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(108))))  severity failure;
	assert RAM(109) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(109))))  severity failure;
	assert RAM(110) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(110))))  severity failure;
	assert RAM(111) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(111))))  severity failure;
	assert RAM(112) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(112))))  severity failure;
	assert RAM(113) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(113))))  severity failure;
	assert RAM(114) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(114))))  severity failure;
	assert RAM(115) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(115))))  severity failure;
	assert RAM(116) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(116))))  severity failure;
	assert RAM(117) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(117))))  severity failure;
	assert RAM(118) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(118))))  severity failure;
	assert RAM(119) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(119))))  severity failure;
	assert RAM(120) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(120))))  severity failure;
	assert RAM(121) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(121))))  severity failure;
	assert RAM(122) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(122))))  severity failure;
	assert RAM(123) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(123))))  severity failure;
	assert RAM(124) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(124))))  severity failure;
	assert RAM(125) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(125))))  severity failure;
	assert RAM(126) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(126))))  severity failure;
	assert RAM(127) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(127))))  severity failure;
	assert RAM(128) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(128))))  severity failure;
	assert RAM(129) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(129))))  severity failure;
	assert RAM(130) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(130))))  severity failure;
	assert RAM(131) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(131))))  severity failure;
	assert RAM(132) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(132))))  severity failure;
	assert RAM(133) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(133))))  severity failure;
	assert RAM(134) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(134))))  severity failure;
	assert RAM(135) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(135))))  severity failure;
	assert RAM(136) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(136))))  severity failure;
	assert RAM(137) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(137))))  severity failure;
	assert RAM(138) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(138))))  severity failure;
	assert RAM(139) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(139))))  severity failure;
	assert RAM(140) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(140))))  severity failure;
	assert RAM(141) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(141))))  severity failure;
	assert RAM(142) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(142))))  severity failure;
	assert RAM(143) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(143))))  severity failure;
	assert RAM(144) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(144))))  severity failure;
	assert RAM(145) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(145))))  severity failure;
	assert RAM(146) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(146))))  severity failure;
	assert RAM(147) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(147))))  severity failure;
	assert RAM(148) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(148))))  severity failure;
	assert RAM(149) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(149))))  severity failure;
	assert RAM(150) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(150))))  severity failure;
	assert RAM(151) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(151))))  severity failure;
	assert RAM(152) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(152))))  severity failure;
	assert RAM(153) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(153))))  severity failure;
	assert RAM(154) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(154))))  severity failure;
	assert RAM(155) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(155))))  severity failure;
	assert RAM(156) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(156))))  severity failure;
	assert RAM(157) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(157))))  severity failure;
	assert RAM(158) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(158))))  severity failure;
	assert RAM(159) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(159))))  severity failure;
	assert RAM(160) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(160))))  severity failure;
	assert RAM(161) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(161))))  severity failure;
	assert RAM(162) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(162))))  severity failure;
	assert RAM(163) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(163))))  severity failure;
	assert RAM(164) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(164))))  severity failure;
	assert RAM(165) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(165))))  severity failure;
	assert RAM(166) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(166))))  severity failure;
	assert RAM(167) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(167))))  severity failure;
	assert RAM(168) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(168))))  severity failure;
	assert RAM(169) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(169))))  severity failure;
	assert RAM(170) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(170))))  severity failure;
	assert RAM(171) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(171))))  severity failure;
	assert RAM(172) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(172))))  severity failure;
	assert RAM(173) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(173))))  severity failure;
	assert RAM(174) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(174))))  severity failure;
	assert RAM(175) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(175))))  severity failure;
	assert RAM(176) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(176))))  severity failure;
	assert RAM(177) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(177))))  severity failure;
	assert RAM(178) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(178))))  severity failure;
	assert RAM(179) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(179))))  severity failure;
	assert RAM(180) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(180))))  severity failure;
	assert RAM(181) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(181))))  severity failure;
	assert RAM(182) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(182))))  severity failure;
	assert RAM(183) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(183))))  severity failure;
	assert RAM(184) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(184))))  severity failure;
	assert RAM(185) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(185))))  severity failure;
	assert RAM(186) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(186))))  severity failure;
	assert RAM(187) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(187))))  severity failure;
	assert RAM(188) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(188))))  severity failure;
	assert RAM(189) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(189))))  severity failure;
	assert RAM(190) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(190))))  severity failure;
	assert RAM(191) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(191))))  severity failure;
	assert RAM(192) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(192))))  severity failure;
	assert RAM(193) = std_logic_vector(to_unsigned(0, 8)) report "TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(193))))  severity failure;

    assert false report "Simulation Ended! TEST PASSATO" severity failure;
end process test;

end projecttb; 
