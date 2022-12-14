library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity soapga_fd is
    port (
        clock               : in std_logic;
        reset               : in std_logic;
        gira_servo          : in std_logic;
        mede_sabao          : in std_logic;
        mede_mao            : in std_logic;
        echo_sabao          : in std_logic;
        echo_mao            : in std_logic;
        sel                 : in std_logic_vector(1 downto 0);
        partida_tx          : in std_logic;
        zera_timer_final    : in std_logic;
        zera_timer_giro     : in std_logic;
        zera_hc             : in std_logic;
        conta_timer_final   : in std_logic;
        conta_timer_giro    : in std_logic;
        pwm                 : out std_logic;
        trigger_sabao       : out std_logic;
        trigger_mao         : out std_logic;
        pronto_mede_sabao   : out std_logic;
        pronto_mede_mao     : out std_logic;
        sseg1               : out std_logic_vector(6 downto 0);
        sseg2               : out std_logic_vector(6 downto 0);
        sseg3               : out std_logic_vector(6 downto 0);
        sseg4               : out std_logic_vector(6 downto 0);
        saida_serial        : out std_logic;
        pronto_tx           : out std_logic;
        fim_timer_final     : out std_logic;
        fim_timer_giro      : out std_logic;
        mao_presente        : out std_logic
    );
end entity;

architecture soapga_fd_arch of soapga_fd is

    component controle_servo_soap is
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            posicao    : in  std_logic;  
            pwm        : out std_logic
        );
    end component;

    component interface_hcsr04 is
        port (
            clock      : in std_logic;
            reset      : in std_logic;
            medir      : in std_logic;
            echo       : in std_logic;
            trigger    : out std_logic;
            medida     : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            pronto     : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0) -- estado da UC
        );
    end component;

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

    component captador_presenca is
        port(
            medida : in std_logic_vector(11 downto 0);
            mao_presente : out std_logic
        );
    end component;

    component conversor_ascii is
        port(
            medida_bit   : in  std_logic_vector(3 downto 0);
            medida_ascii : out std_logic_vector(6 downto 0)
        );
    end component;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    component mux_4x1_n is
        generic (
            constant BITS: integer := 4
        );
        port( 
            D3      : in  std_logic_vector (BITS-1 downto 0);
            D2      : in  std_logic_vector (BITS-1 downto 0);
            D1      : in  std_logic_vector (BITS-1 downto 0);
            D0      : in  std_logic_vector (BITS-1 downto 0);
            SEL     : in  std_logic_vector (1 downto 0);
            MUX_OUT : out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    component tx_serial_7E2 is
        port (
            clock         : in  std_logic;
            reset         : in  std_logic;
            partida       : in  std_logic;
            dados_ascii   : in  std_logic_vector (6 downto 0);
            saida_serial  : out std_logic;
            pronto        : out std_logic
        );
    end component;

    signal s_medida_sabao, s_medida_mao : std_logic_vector(11 downto 0);
    signal s_uni_ascii, s_dez_ascii, dado_ascii : std_logic_vector(6 downto 0);
    signal s_pronto_medir1 : std_logic;

begin

    SERVO: controle_servo_soap
        port map(
            clock      => clock,
            reset      => reset, 
            posicao    => gira_servo,
            pwm        => pwm
        );

    MEDESOAP: interface_hcsr04
        port map(
            clock      => clock,
            reset      => reset,
            medir      => mede_sabao,
            echo       => echo_sabao,
            trigger    => trigger_sabao,
            medida     => s_medida_sabao,
            pronto     => pronto_mede_sabao,
            db_estado  => open
        );

    MEDEMAO: interface_hcsr04
        port map(
            clock      => clock,
            reset      => reset,
            medir      => mede_mao,
            echo       => echo_mao,
            trigger    => trigger_mao,
            medida     => s_medida_mao,
            pronto     => pronto_mede_mao,
            db_estado  => open
        );

    CAP: captador_presenca
        port map(
            medida        =>    s_medida_mao,
            mao_presente  =>    mao_presente
        );
    

    HEX1: hex7seg
        port map(
            hexa => s_medida_mao(3 downto 0),
            sseg => sseg1
        );

    HEX2: hex7seg
        port map(
            hexa => s_medida_mao(7 downto 4),
            sseg => sseg2
        );

    HEX3: hex7seg
        port map(
            hexa => s_medida_sabao(3 downto 0),
            sseg => sseg3
        );

    HEX4: hex7seg
        port map(
            hexa => s_medida_mao(7 downto 4),
            sseg => sseg4
        );

    ASCIIU: conversor_ascii
        port map(
            medida_bit   => s_medida_sabao(3 downto 0),
            medida_ascii => s_uni_ascii
        );

    ASCIID: conversor_ascii
        port map(
            medida_bit   => s_medida_sabao(7 downto 4),
            medida_ascii => s_dez_ascii
        );

    MUX: mux_4x1_n
        generic map(
            BITS => 7
        )
        port map (
            D3       => "0100011",
            D2       => s_uni_ascii,
            D1       => s_dez_ascii,
            D0       => "1000001",
            SEL      => sel,
            MUX_OUT  => dado_ascii
        );

    TXSAB: tx_serial_7E2
        port map(
            clock         => clock,
            reset         => reset,
            partida       => partida_tx,
            dados_ascii   => dado_ascii,
            saida_serial  => saida_serial,
            pronto        => pronto_tx
        );

    TFIM: contador_m
        generic map(
            M => 100000000,  --50000000=1s
            N => 28
        )
        port map(
            clock => clock, 
            zera  => zera_timer_final,
            conta => conta_timer_final,
            Q     => open,
            fim   => fim_timer_final,
            meio  => open
        );

    TGIRO: contador_m
        generic map(
            M => 100000000,  
            N => 28
        )
        port map(
            clock => clock,
            zera  => zera_timer_giro,
            conta => conta_timer_giro,
            Q     => open, 
            fim   => fim_timer_giro,
            meio  => open
        );

    pronto_medir1 <= s_pronto_medir1;
    db_pronto_medir1 <= s_pronto_medir1;
end architecture;
