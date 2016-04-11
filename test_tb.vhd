library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_tb is
end test_tb;

architecture main of test_tb is
   signal a, b : unsigned(12 downto 0);
   signal dir_a, dir_b : std_logic_vector(2 downto 0);
   signal dir  : std_logic_vector(2 downto 0);
   signal max : unsigned(12 downto 0);

   
begin
  
   uut : entity work.max(main)
     port map (
       i_a    => a,
       i_b    => b,
       i_dir_a  => dir_a,
       i_dir_b  => dir_b,
       o_dir => dir,
       o_max => max
     );

  process
  begin
    -- --------------------
    a <= to_unsigned(7, 13); b <= to_unsigned(7, 13); dir_a <= "001"; dir_b <= "010";
    wait for 100 ns;
  end process;
   
end main;
