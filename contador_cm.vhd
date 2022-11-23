--------------------------------------------------------------------
-- Arquivo   : contador_cm.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : circuito de conversao de
--             largura de pulso para centimetros 
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm is
    generic (
        constant R : integer;
        constant N : integer
    );
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        pulso   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        pronto  : out std_logic
    );
end entity;

architecture contador_cm_structure of contador_cm is

    component contador_m is
        generic (
            constant M : integer := 50;  
            constant N : integer := 6 
        );
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component;

    component contador_bcd_3digitos is
        port ( 
            clock   : in  std_logic;
            zera    : in  std_logic;
            conta   : in  std_logic;
            digito0 : out std_logic_vector(3 downto 0);
            digito1 : out std_logic_vector(3 downto 0);
            digito2 : out std_logic_vector(3 downto 0);
            fim     : out std_logic
        );
    end component;

    signal s_tick : std_logic;
    signal valor, s_digito : std_logic_vector(11 downto 0);

begin

    CONTM: contador_m
        generic map(
            M => R,
            N => N
        )
        port map(
            clock => clock,
            zera  => reset, 
            conta => pulso,
            Q     => valor,
            fim   => open,
            meio  => s_tick
        );
    
    CONTBCD: contador_bcd_3digitos 
        port map(
            clock    => clock,
            zera     => reset,
            conta    => s_tick,
            digito0  => s_digito(3 downto 0),
            digito1  => s_digito(7 downto 4),
            digito2  => s_digito(11 downto 8),
            fim      => open
        );

    pronto <= '1' when pulso = '0' and to_integer(unsigned(s_digito)) > 0 else
              '0';

    digito0 <= s_digito(3 downto 0);
    digito1 <= s_digito(7 downto 4);
    digito2 <= s_digito(11 downto 8);

end architecture;