library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage_12 is

  port(
    im1l      : in  unsigned(7 downto 0);
    im1r      : in  unsigned(7 downto 0);
    ia1l      : in  unsigned(7 downto 0);
    ia1r      : in  unsigned(7 downto 0);
    im1ld     : in  std_logic_vector(2 downto 0);
    im1rd     : in  std_logic_vector(2 downto 0);
    im2l      : in  unsigned(7 downto 0);
    im2r      : in  unsigned(7 downto 0);
    ia2l      : in  unsigned(7 downto 0);
    ia2r      : in  unsigned(7 downto 0);
    im2ld     : in  std_logic_vector(2 downto 0);
    im2rd     : in  std_logic_vector(2 downto 0);
    o_dir     : out std_logic_vector(2 downto 0);
    o_add     : out unsigned(8 downto 0);
    o_add2    : out unsigned(9 downto 0);
    clk       : in  std_logic;
    i_s       : in  std_logic_vector(7 downto 0)
  );

end entity;

architecture main of stage_12 is

  --< STAGE 1 >
  signal a1   : unsigned(8 downto 0);
  signal m1   : unsigned(7 downto 0);
  signal d1   : std_logic_vector(2 downto 0);
  signal a2   : unsigned(8 downto 0);
  signal m2   : unsigned(7 downto 0);
  signal d2   : std_logic_vector(2 downto 0);

  signal ra1  : unsigned(8 downto 0);
  signal rm1  : unsigned(7 downto 0);
  signal rmd1 : std_logic_vector(2 downto 0);
  signal ra2  : unsigned(8 downto 0);
  signal rm2  : unsigned(7 downto 0);
  signal rmd2 : std_logic_vector(2 downto 0);
  signal sel  : std_logic;

  --< STAGE 2 >
  signal a3   : unsigned(9 downto 0);
  signal a4   : unsigned(9 downto 0);
  
  signal ra3  : unsigned(9 downto 0);
  signal ra4  : unsigned(9 downto 0);

begin
  --< STAGE 1 >
  max1 : entity work.max(main)
    generic map ( bit_num => 8 )
    port map (
      i_a     => im1l,
      i_b     => ia1r,
      i_dir_a => im1ld,
      i_dir_b => im1rd,
      o_dir   => d1,
      o_max   => m1
      );

  max2 : entity work.max(main)
    generic map ( bit_num => 8 )
    port map (
      i_a     => im2l,
      i_b     => ia2r,
      i_dir_a => im2ld,
      i_dir_b => im2rd,
      o_dir   => d2,
      o_max   => m2
      );

  a1 <= resize(im1r, 9) + ia1l;
  a2 <= resize(im2r, 9) + ia2l;

  process
  begin
    wait until rising_edge(clk);
    ra1 <= a1;
  end process;

  process
  begin
    wait until rising_edge(clk);
    rm1 <= m1;
  end process;

  process
  begin
    wait until rising_edge(clk);
    rmd1 <= d1;
  end process;

  process
  begin
    wait until rising_edge(clk);
    ra2 <= a2;
  end process;

  process
  begin
    wait until rising_edge(clk);
    rm2 <= m2;
  end process;

  process
  begin
    wait until rising_edge(clk);
    rmd2 <= d2;
  end process;

  sel <= i_s(2) or i_s(4);
  o_add <= ra1 when sel = '1' else ra2;
  o_dir <= rmd1 when sel = '1' else rmd2;

  --< STAGE 2 >
  a3 <= resize(ra1, 10) + rm1;
  a4 <= resize(ra2, 10) + rm2;

  process
  begin
    wait until rising_edge(clk);
    ra3 <= a3;
  end process;

  process
  begin
    wait until rising_edge(clk);
    ra4 <= a4;
  end process;

  o_add2 <= ra4 when sel = '1' else ra3;

end architecture;
