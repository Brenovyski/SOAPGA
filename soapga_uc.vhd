library ieee;
use ieee.std_logic_1164.all;

entity soapga_uc is 
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
end soapga_uc;

architecture soapga_uc_arch of soapga_uc is
    type tipo_estado is (inicial, preparacao, mede_mao, 
                         timer_giro, reposiciona, mede_sabao, 
                         load_id, tx_id, 
                         load_dez_dist, tx_dez_dist, 
                         load_uni_dist, tx_uni_dist, 
                         load_hash_dist, tx_hash_dist, 
                         timer_fim);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (ligar, pronto_mede_mao, pronto_mede_sabao, mao_presente, fim_timer_final, fim_timer_giro, pronto_tx, Eatual) 
    begin
      case Eatual is
        when inicial =>         if ligar='1' then Eprox <= preparacao;
                                else              Eprox <= inicial;
                                end if;
        when preparacao =>      Eprox <= mede_mao;
        when mede_mao =>        if pronto_mede_mao='0' then Eprox <= mede_mao;
                                elsif mao_presente='1' and pronto_mede_mao='1' then Eprox <= timer_giro;
                                else                        Eprox <= timer_fim;
                                end if;

        when timer_giro  =>     if fim_timer_giro='1' then Eprox <= reposiciona;
                                else                    Eprox <= timer_giro;
                                end if;

        when reposiciona =>     Eprox <= mede_sabao;  
        when mede_sabao =>      if pronto_mede_sabao='1' then Eprox <= load_id;
                                else                     Eprox <= mede_sabao;
                                end if;

        when load_id    =>      Eprox <= tx_id;
        when tx_id      =>      if pronto_tx='1' then Eprox <= load_dez_dist;
                                else                    Eprox <= tx_id;
                                end if;
     
        when load_dez_dist   => Eprox <= tx_dez_dist;  
        when tx_dez_dist     => if pronto_tx='1' then Eprox <= load_uni_dist;
                                else                  Eprox <= load_dez_dist;
                                end if;
        when load_uni_dist   => Eprox <= tx_uni_dist;  
        when tx_uni_dist     => if pronto_tx='1' then Eprox <= load_hash_dist;
                                else                  Eprox <= load_uni_dist;
                                end if;
        when load_hash_dist  => Eprox <= tx_hash_dist;  
        when tx_hash_dist    => if pronto_tx='1' then Eprox <= timer_fim;
                                else                  Eprox <= load_hash_dist;
                                end if;                                          
        when timer_fim       => if fim_timer_final='1' then Eprox <= mede_mao;
                                else                   Eprox <= timer_fim;
                                end if;
        when others          => Eprox <= inicial;
      end case;
    end process;

with Eatual select 
    zera <= '1' when preparacao, '0' when others;

with Eatual select
    mede_mao <= '1'when mede_mao, '0' when others;

with Eatual select
    zera_timer_final <= '1'when mede_mao | tx_hash_dist, '0' when others;

with Eatual select
    zera_timer_giro <= '1'when mede_mao, '0' when others;

with Eatual select 
    zera_hc <= '1' when timer_fim, '0' when others;

with Eatual select
    conta_timer_final <= '1' when timer_fim, '0' when others;

with Eatual select
    gira_servo <= '1' when timer_giro, '0' when others;

with Eatual select
    conta_timer_giro <= '1' when timer_giro, '0' when others;

with Eatual select
    mede_sabao <= '1'when mede_sabao, '0' when others;

with Eatual select
    sel      <= "01" when load_dez_dist, 
                "10" when load_uni_dist,
                "11" when load_hash_dist,  
                "00" when others;

with Eatual select
    partida_tx <= '1' when tx_id | tx_dez_dist | tx_uni_dist | tx_hash_dist, '0' when others;

with Eatual select
    db_estado <= "0000" when inicial, 
                 "0001" when preparacao, 
                 "0010" when mede_mao, 
                 "0011" when timer_giro,
                 "0100" when reposiciona, 
                 "0101" when mede_sabao,
                 "0110" when load_id, 
                 "0111" when tx_id,  
                 "1000" when load_dez_dist, 
                 "1001" when tx_dez_dist, 
                 "1010" when load_uni_dist, 
                 "1011" when tx_uni_dist, 
                 "1100" when load_hash_dist, 
                 "1101" when tx_hash_dist, 
                 "1111" when timer_fim, 
                 "1111" when others;

end architecture soapga_uc_arch;