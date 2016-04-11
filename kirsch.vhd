library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity kirsch is
  port(
    ------------------------------------------
    -- main inputs and outputs
    i_clock    : in  std_logic;
    i_reset    : in  std_logic;
    i_valid    : in  std_logic;
    i_pixel    : in  std_logic_vector(7 downto 0);
    o_valid    : out std_logic;
    o_edge     : out std_logic;
    o_dir      : out std_logic_vector(2 downto 0);
    o_mode     : out std_logic_vector(1 downto 0);
    o_row      : out std_logic_vector(7 downto 0);
    ------------------------------------------
    -- debugging inputs and outputs
    debug_key      : in  std_logic_vector( 3 downto 1) ;
    debug_switch   : in  std_logic_vector(17 downto 0) ;
    debug_led_red  : out std_logic_vector(17 downto 0) ;
    debug_led_grn  : out std_logic_vector(5  downto 0) ;
    debug_num_0    : out std_logic_vector(3 downto 0) ;
    debug_num_1    : out std_logic_vector(3 downto 0) ;
    debug_num_2    : out std_logic_vector(3 downto 0) ;
    debug_num_3    : out std_logic_vector(3 downto 0) ;
    debug_num_4    : out std_logic_vector(3 downto 0) ;
    debug_num_5    : out std_logic_vector(3 downto 0)
    ------------------------------------------
  );  
end entity;


architecture main of kirsch is

  subtype pixel is std_logic_vector(7 downto 0);
  type    p_buffer is array (2 downto 0) of pixel;

  -- buffer for convolution matrix
  signal col0, col1, col2 : p_buffer;

  signal p_mid, p_top     : std_logic_vector(7 downto 0);

  -- mem signals
  signal we               : std_logic_vector(1 downto 0);
  signal q0, q1           : std_logic_vector(7 downto 0);

  -- system signals
  signal s                : std_logic_vector(7 downto 0); --state
  signal max_col          : std_logic;
  signal v                : std_logic_vector(8 downto 0); --o_valid

  signal a1, a1_i1        : std_logic_vector(7 downto 0);
  signal a1_i2            : unsigned(0 downto 0);

  -- row/column count
  signal row_cnt, col_cnt : std_logic_vector(7 downto 0);

  -- stage 1/2
  signal sl1, cl1, cr1, sr1 : std_logic_vector(7 downto 0);
  signal dl1, dr1           : std_logic_vector(2 downto 0);
  signal sl2, cl2, cr2, sr2 : std_logic_vector(7 downto 0);
  signal dl2, dr2           : std_logic_vector(2 downto 0);
  --temp
  signal od                 : std_logic_vector(2 downto 0);
  signal oa                 : unsigned(8 downto 0);
  signal oa2                : unsigned(9 downto 0);

  -- stage 3/4
  signal r1                 : std_logic_vector(2 downto 0);
  --temp
  signal od2                : std_logic_vector(2 downto 0);
  signal oe                 : std_logic;

begin
  --< SYSTEM >
  -- state
  s(0) <= i_valid;

  process
  begin
    wait until rising_edge(i_clock);
    if (i_reset = '1') then
      s(7 downto 1) <= (others => '0');
    else
      s(7 downto 1) <= s(6 downto 0);
    end if;
  end process;
 
  -- inter-parcel variables
  process
  begin
    wait until rising_edge(i_clock);
    if s(1) = '1' or i_reset = '1' then
      if i_reset = '1' then
        col_cnt <= (others => '0');
      else
        col_cnt <= a1;
      end if;
    end if;
  end process;

  process
  begin
    wait until rising_edge(i_clock);
    if s(2) = '1' or i_reset = '1' then
      if i_reset = '1' then
        row_cnt <= (others => '0');
      else
        row_cnt <= a1;
      end if;
    end if;
  end process;

  max_col <= '1' when unsigned(col_cnt) = 0 else '0';
  a1 <= std_logic_vector(unsigned(a1_i1) + a1_i2);
  a1_i2 <= to_unsigned(0, 1) when s(2) = '1' and max_col = '0' else to_unsigned(1, 1);
  a1_i1 <= col_cnt when s(1) = '1' else row_cnt;

  --< MEM >
  -- cells
  mem0 : entity work.mem(main)
    port map (
      address => col_cnt,
      clock   => i_clock,
      data    => i_pixel,
      wren    => we(0),
      q       => q0
      );

  mem1 : entity work.mem(main)
    port map (
      address => col_cnt,
      clock   => i_clock,
      data    => i_pixel,
      wren    => we(1),
      q       => q1
      );

  -- write selection logic
  we(1) <= s(0) when row_cnt(0) = '1' else '0';
  we(0) <= '0' when row_cnt(0) = '1' else s(0);

  --< INPUT MANAGEMENT >
  -- convolution matrix buffer
  process
  begin
    wait until rising_edge(i_clock);
    if (s(0) = '1') then
      col2(0) <= i_pixel;
    end if;
  end process;

  process
  begin
    wait until rising_edge(i_clock);
    if (s(3) = '1') then
      col2(2) <= p_top;
      col2(1) <= p_mid;
    end if;
  end process;

  process
  begin
    wait until rising_edge(i_clock);
    if (s(3) = '1') then
      col1 <= col2;
    end if;
  end process;

  process
  begin
    wait until rising_edge(i_clock);
    if (s(3) = '1') then
      col0 <= col1;
    end if;
  end process;

  p_mid <= q0 when row_cnt(0) = '1' else q1;
  p_top <= q1 when row_cnt(0) = '1' else q0;

  --< STAGE 1 > Initial component calculations
  --< STAGE 2 > Component calculation summer

  stage_12 : entity work.stage_12(main)
    port map (
      im1l => unsigned(sl1),
      im1r => unsigned(cl1),
      ia1l => unsigned(cr1),
      ia1r => unsigned(sr1),
      im1ld => dl1,
      im1rd => dr1,
      im2l => unsigned(sl2),
      im2r => unsigned(cl2),
      ia2l => unsigned(cr2),
      ia2r => unsigned(sr2),
      im2ld => dl2,
      im2rd => dr2,
      o_dir => od,
      o_add => oa,
      o_add2 => oa2,
      clk => i_clock,
      i_s => s
    );

  sl1 <= col0(2) when s(1) = '1' else col2(0);
  sr1 <= col2(1) when s(1) = '1' else col0(1);
  cl1 <= col1(2) when s(1) = '1' else col1(0);
  cr1 <= col2(2) when s(1) = '1' else col0(0);
 
  sl2 <= col0(0) when s(0) = '1' else col2(2);
  sr2 <= col1(2) when s(0) = '1' else col1(0);
  cl2 <= col0(1) when s(0) = '1' else col2(1);
  cr2 <= col0(2) when s(0) = '1' else col2(0);

  dl1(2 downto 1) <= "01";
  dl1(0) <= s(3);

  dr1(2 downto 1) <= "11";
  dr1(0) <= s(3);
  
  dl2(2 downto 1) <= "00";
  dl2(0) <= s(0);

  dr2(2 downto 1) <= "10";
  dr2(0) <= s(2);

  --< STAGE 3 > Matrix final calculations
  --< STAGE 4 > Edge determination
  stage_34 : entity work.stage_34(main)
    port map (
      i1 => oa2,
      i2 => (others => '0'),
      i3 => oa,
      i4 => (others => '0'),
      id1 => r1,
      id2 => (others => '0'),
      i_s => s,
      o_dir => od2,
      o_edge => oe,
      clk => i_clock
    );

  process
  begin
    wait until rising_edge(i_clock);
    r1 <= od;
  end process;

  --< OUTPUTS >
  v(0) <= i_valid when unsigned(row_cnt) >= 2 and unsigned(col_cnt) >= 2 else '0';

  process
  begin
    wait until rising_edge(i_clock);
    if (i_reset = '1') then
      v(8 downto 1) <= (others => '0');
    else
      v(8 downto 1) <= v(7 downto 0);
    end if;
  end process;

  o_valid <= v(8);
  o_mode(1) <= not i_reset;
  o_mode(0) <= '0' when unsigned(row_cnt) = 0 and unsigned(col_cnt) = 0
                        and unsigned(s) = 0 and i_reset = '0' else '1';
  o_row <= row_cnt;
  o_dir <= od2 when oe = '1' else "000";
  o_edge <= oe;

  debug_num_5 <= row_cnt(7 downto 4);
  debug_num_4 <= row_cnt(3 downto 0);
  debug_num_3 <= (others => '0');
  debug_num_2 <= (others => '0');
  debug_num_1 <= col_cnt(7 downto 4);
  debug_num_0 <= col_cnt(3 downto 0);

  debug_led_red <= (others => '0');
  debug_led_grn <= (others => '0');

end architecture;
