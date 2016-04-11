library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity max is
  generic(
    bit_num : natural := 8
  );
  port(
    ------------------------------------------
    -- main inputs and outputs
    i_a     : in  unsigned(bit_num-1 downto 0);                      
    i_b     : in  unsigned(bit_num-1 downto 0);                     
    i_dir_a : in  std_logic_vector(2 downto 0);           
    i_dir_b : in  std_logic_vector(2 downto 0);
    o_dir   : out std_logic_vector(2 downto 0);               
    o_max   : out unsigned(bit_num-1 downto 0)
  );
end entity;


architecture main of max is
  signal a_gt_b : std_logic;
begin 
  a_gt_b <= '1' when i_a >= i_b else '0';
  o_dir <= i_dir_a when a_gt_b = '1' else i_dir_b;
  o_max <= i_a when a_gt_b = '1' else i_b;
end architecture;
