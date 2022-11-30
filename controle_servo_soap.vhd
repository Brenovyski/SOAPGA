library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_soap is
  port (
      clock      : in  std_logic;
      reset      : in  std_logic;
      posicao    : in  std_logic;  
      pwm        : out std_logic
  );
end entity;

architecture rtl of controle_servo_soap is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- valor para frequencia da saida de 50Hz 
                                                  -- ou periodo de 20ms
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal posicao_controle  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_posicao    : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(clock, reset, s_posicao)
  begin
    -- inicia contagem e posicao
    if(reset='1') then
      contagem    <= 0;
      pwm         <= '0';
      posicao_controle <= s_posicao;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < posicao_controle) then
          pwm    <= '1';   
        else
          pwm    <= '0';
        end if;
        -- atualiza contagem e posicao
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          posicao_controle <= s_posicao;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(posicao)
  begin
		case posicao is
			--when "000"  =>    s_posicao <=   35000;  -- pulso de 0,700ms 
			when '0'  =>    s_posicao <=   67150;  -- pulso de 1,343ms
			--when "010"  =>    s_posicao <=   56450;  -- pulso de 1,129ms
			--when "011"  =>    s_posicao <=   67150;  -- pulso de 1,343ms
			--when "100"  =>    s_posicao <=   77850;  -- pulso de 1,557ms
			--when "101"  =>    s_posicao <=   88550;  -- pulso de 1,771ms
			when '1'  =>    s_posicao <=   99300;  -- pulso de 1,986ms
			--when "111"  =>    s_posicao <=  110000;  -- pulso de 2,200ms
			when others =>    s_posicao <=       0;  -- nulo   saida 0
		end case;
  end process;
  
end architecture;