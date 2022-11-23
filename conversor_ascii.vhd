library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conversor_ascii is
    port(
        medida_bit   : in  std_logic_vector(3 downto 0);
        medida_ascii : out std_logic_vector(6 downto 0)
    );
end entity;

architecture conversor_ascii_structure of conversor_ascii is
begin
    medida_ascii <= "011" & medida_bit;
end architecture;