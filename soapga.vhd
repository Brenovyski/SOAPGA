library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity soapga is
    port(
        clock           : in std_logic;
        reset           : in std_logic;
        ligar           : in std_logic;
        echo_sabao      : in std_logic;
        echo_mao        : in std_logic;
        pwm             : out std_logic;
        trigger_sabao   : out std_logic;
        trigger_mao     : out std_logic;
        saida_serial    : out std_logic;
        sseg1           : out std_logic_vector(6 downto 0);
        sseg2           : out std_logic_vector(6 downto 0);
        sseg3           : out std_logic_vector(6 downto 0);
        sseg4           : out std_logic_vector(6 downto 0);
        db_estado       : out std_logic_vector(6 downto 0)
    );
end entity;

architecture soapga_arch of soapga is

    component soapga_uc is 
        port ( 
            clock               : in  std_logic;
            reset               : in  std_logic;
            ligar               : in  std_logic;
            pronto_mede_mao     : in  std_logic;
            pronto_mede_sabao   : in  std_logic;
            mao_presente        : in  std_logic;
            fim_timer_final     : in  std_logic;
            fim_timer_giro      : in  std_logic;
            pronto_tx           : in  std_logic;
            zera                : out std_logic;
            mede_mao            : out std_logic;
            mede_sabao          : out std_logic;
            zera_timer_final    : out std_logic;
            zera_timer_giro     : out std_logic;
            zera_hc             : out std_logic;
            conta_timer_final   : out std_logic;
            conta_timer_giro    : out std_logic;
            gira_servo          : out std_logic;
            partida_tx          : out std_logic;
            sel                 : out std_logic_vector(1 downto 0); 
            db_estado           : out std_logic_vector(3 downto 0)
        );
    end component;

    component soapga_fd is
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
    end component;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_pronto_mede_mao, s_pronto_mede_sabao, s_mao_presente, s_fim_timer_final, s_fim_timer_giro, s_pronto_tx,
           s_zera, s_mede_mao, s_mede_sabao, s_zera_timer_final, s_zera_timer_giro, s_conta_timer_final, s_conta_timer_giro,
           s_gira_servo, s_partida_tx, s_zera_hc : std_logic;
    
    signal s_db_estado, s_db_estado_soap : std_logic_vector(3 downto 0);
	signal s_sel : std_logic_vector(1 downto 0);
    
begin

    UC: soapga_uc
        port map(
            clock               => clock,
            reset               => reset,
            ligar               => ligar,
            pronto_mede_mao     => s_pronto_mede_mao, 
            pronto_mede_sabao   => s_pronto_mede_sabao,
            mao_presente        => s_mao_presente,
            fim_timer_final     => s_fim_timer_final,
            fim_timer_giro      => s_fim_timer_giro,
            pronto_tx           => s_pronto_tx,
            zera                => s_zera,
            mede_mao            => s_mede_mao,
            mede_sabao          => s_mede_sabao,
            zera_timer_final    => s_zera_timer_final,
            zera_timer_giro     => s_zera_timer_giro,
            zera_hc             => s_zera_hc,
            conta_timer_final   => s_conta_timer_final,
            conta_timer_giro    => s_conta_timer_giro,
            gira_servo          => s_gira_servo,
            partida_tx          => s_partida_tx,
            sel                 => s_sel,
            db_estado           => s_db_estado
        );

    FD: soapga_fd
        port map(
            clock               => clock,
            reset               => s_zera,
            gira_servo          => s_gira_servo,
            mede_sabao          => s_mede_sabao,
            mede_mao            => s_mede_mao,
            echo_sabao          => echo_sabao,
            echo_mao            => echo_mao,
            sel                 => s_sel,
            partida_tx          => s_partida_tx,
            zera_timer_final    => s_zera_timer_final,
            zera_timer_giro     => s_zera_timer_giro,
            zera_hc             => s_zera_hc,
            conta_timer_final   => s_conta_timer_final,
            conta_timer_giro    => s_conta_timer_giro,
            pwm                 => pwm,
            trigger_sabao       => trigger_sabao,
            trigger_mao         => trigger_mao,
            pronto_mede_sabao   => s_pronto_mede_sabao,
            pronto_mede_mao     => s_pronto_mede_mao,
            sseg1               => sseg1,
            sseg2               => sseg2,
            sseg3               => sseg3,
            sseg4               => sseg4,
            saida_serial        => saida_serial,
            pronto_tx           => s_pronto_tx,
            fim_timer_final     => s_fim_timer_final,
            fim_timer_giro      => s_fim_timer_giro,
            mao_presente        => s_mao_presente
        );

    UCSTATE: hex7seg
        port map(
            hexa => s_db_estado,
            sseg => db_estado
        );

    UCHCSOAO: hex7seg
        port map(
            hexa => s_db_estado_soap,
            sseg => db_estado_soap
        );

    db_pronto_medir1 <= s_pronto_medir1;
        

end architecture;

