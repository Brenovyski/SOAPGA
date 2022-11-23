--------------------------------------------------------------------
-- Arquivo   : interface_hcsr04_fd.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito
--             da interface HC-SR04
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_fd is
    port(
        clock       : in std_logic;
        pulso       : in std_logic;
        gera        : in std_logic;
        zera        : in std_logic;
        registra    : in std_logic;
        fim_medida  : out std_logic;
        distancia   : out std_logic_vector(11 downto 0);
        trigger     : out std_logic
    );
end entity;

architecture interface_hcsr04_fd_structure of interface_hcsr04_fd is

    component contador_cm is 
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
    end component;

    component registrador_n is
        generic (
            constant N: integer := 8 
        );
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            enable : in  std_logic;
            D      : in  std_logic_vector (N-1 downto 0);
            Q      : out std_logic_vector (N-1 downto 0)
        );
    end component;

    component gerador_pulso is
        generic (
            largura: integer:= 25
        );
        port(
            clock  : in  std_logic;
            reset  : in  std_logic;
            gera   : in  std_logic;
            para   : in  std_logic;
            pulso  : out std_logic;
            pronto : out std_logic
        );
end component;

    signal s_distancia : std_logic_vector(11 downto 0);
begin

    CONTCM: contador_cm
        generic map(
            R => 2941,
            N => 12
        )
        port map(
            clock   => clock, 
            reset   => zera,
            pulso   => pulso,
            digito0 => s_distancia(3 downto 0),
            digito1 => s_distancia(7 downto 4),
            digito2 => s_distancia(11 downto 8),
            pronto  => fim_medida
        );

    REGDIST: registrador_n
        generic map(
            N => 12
        )
        port map(
            clock  => clock,
            clear  => zera,
            enable => registra,
            D      => s_distancia,
            Q      => distancia
        );

    
    GPULSO: gerador_pulso
        generic map(
            largura => 500 -- 10us/20ns = 500 ciclos
        )
        port map(
            clock  => clock,
            reset  => zera,
            gera   => gera,
            para   => '0',
            pulso  => trigger,
            pronto => open
        );



end architecture;