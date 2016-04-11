library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage_34 is

  port(
    i1      : in  unsigned(9 downto 0); --m1
    i2      : in  unsigned(9 downto 0); --m1
    i3      : in  unsigned(8 downto 0); --a1
    i4      : in  unsigned(8 downto 0); --a1
    id1     : in  std_logic_vector(2 downto 0);
    id2     : in  std_logic_vector(2 downto 0);
    i_s     : in  std_logic_vector(7 downto 0);
    o_dir   : out std_logic_vector(2 downto 0);
    o_edge  : out std_logic;
    clk     : in  std_logic
  );

end entity;

architecture main of stage_34 is

  -- stage 3a
  signal m1src1  : unsigned(9 downto 0);
  signal m1src1d : std_logic_vector(2 downto 0);
  signal m1d     : std_logic_vector(2 downto 0);
  signal m1      : unsigned(9 downto 0);

  signal r2      : unsigned(9 downto 0);
  signal r3      : std_logic_vector(2 downto 0);

  -- stage 3b
  signal a1      : unsigned(10 downto 0);
  signal a1src2  : unsigned(10 downto 0);

  signal r1      : unsigned(10 downto 0);

  -- stage 4
  signal a2 : unsigned(12 downto 0);
  signal a2src1  : unsigned(12 downto 0);
  signal a2src2  : unsigned(12 downto 0);
  signal s1 : unsigned(11 downto 0);
  signal s2 : unsigned(12 downto 0);
  signal c1 : std_logic;

  signal r4 : unsigned(12 downto 0);
  signal r5 : unsigned(12 downto 0);
  signal r6 : std_logic;
  signal r7 : std_logic_vector(2 downto 0);

begin

  --< STAGE 3A >
  max1 : entity work.max(main)
    generic map ( bit_num => 10 )
    port map (
      i_a     => m1src1,
      i_b     => i1,
      i_dir_a => m1src1d,
      i_dir_b => id1,
      o_dir   => m1d,
	  o_max   => m1
      );

  m1src1 <= i2 when i_s(2) = '1' else r2;
  m1src1d <= id2 when i_s(2) = '1' else r3;

  process
  begin
    wait until rising_edge(clk);
    r2 <= m1;
  end process;

  process
  begin
    wait until rising_edge(clk);
    r3 <= m1d;
  end process;

  --< STAGE 3B >
  a1 <= i3 + a1src2;
  a1src2 <= resize(i4, 11) when i_s(1) = '1' else r1;

  process
  begin
    wait until rising_edge(clk);
    r1 <= a1;
  end process;

  --< STAGE 4 >
  a2src1 <= resize(r1, 13) when i_s(5) = '1' else r4;
  a2src2 <= to_unsigned(383, 13) when i_s(5) = '1' else r5;

  s1 <= shift_left(resize(r1, 12), 1);
  s2 <= shift_left(resize(r2, 13), 3);
  a2 <= a2src1 + a2src2;
  c1 <= '1' when r4 > r5 else '0';

  process
  begin
    wait until rising_edge(clk);
	if i_s(5) = '1' then
	  r4 <= resize(s1, 13);
	else
      r4 <= s2;
	end if;
  end process;

  process
  begin
    wait until rising_edge(clk);
    r5 <= a2;
  end process;

  process
  begin
    wait until rising_edge(clk);
	if i_s(7) = '1' then
	  r6 <= c1;
	end if;
  end process;

  process
  begin
    wait until rising_edge(clk);
	if i_s(6) = '1' then
	  r7 <= r3;
	end if;
  end process;

  o_edge <= r6;
  o_dir <= r7;

end architecture;
