library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity captador_presenca is
    port(
        medida : in std_logic_vector(11 downto 0);
        mao_presente : out std_logic
    );
end entity;

architecture captador_presenca_arch of captador_presenca is
begin
    mao_presente <= '1' when to_integer(unsigned(medida)) < 3 else
                    '0';
end architecture;