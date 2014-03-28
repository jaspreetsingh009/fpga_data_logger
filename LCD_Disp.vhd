library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LCD_Disp is
port( Clk       : IN  STD_LOGIC := '0';
      LCD_RS    : OUT STD_LOGIC;
      LCD_E     : OUT STD_LOGIC;	
      LCD_Data  : IN  STD_LOGIC_VECTOR(11 downto 0) := "000000000000";
      WaveSel   : IN  STD_LOGIC_VECTOR(2 downto 0);
      DataOut   : OUT STD_LOGIC_VECTOR(7 downto 0));
end entity;

architecture LCD_Disp_arc of LCD_Disp is

constant N : INTEGER := 21;
Type arrayData is array (0 to N) of STD_LOGIC_VECTOR(7 downto 0);

signal Datas: arrayData;
signal TempVal   : INTEGER;
signal TempVal_1 : INTEGER;
signal TempVal_2 : INTEGER;
signal TempVal_3 : INTEGER;
signal TempVal_4 : INTEGER;

begin

--Commands--

Datas(0)  <= X"38";
Datas(1)  <= X"0c";
Datas(2)  <= X"06";
Datas(3)  <= X"80";

--Datas--

Datas(4)  <= x"44";
Datas(5)  <= x"41";
Datas(6)  <= x"54";
Datas(7)  <= x"41";
Datas(8)  <= x"3A";
Datas(9) <= x"20";

TempVal   <= (3300 * (to_integer(UNSIGNED(LCD_Data))))/4095;
TempVal_1 <= (TempVal) mod 10;
TempVal_2 <= (TempVal/10) mod 10;
TempVal_3 <= (TempVal/100) mod 10;
TempVal_4 <= (TempVal/1000);

with (TempVal_1) select
Datas(14) <= x"30" when 0,
             x"31" when 1,
	     x"32" when 2,
	     x"33" when 3,
	     x"34" when 4,
	     x"35" when 5,
	     x"36" when 6,
	     x"37" when 7,
	     x"38" when 8,
	     x"39" when 9,
	     x"30" when others;
				 
with (TempVal_2) select
Datas(13) <= x"30" when 0,
             x"31" when 1,
	     x"32" when 2,
	     x"33" when 3,
	     x"34" when 4,
	     x"35" when 5,
    	     x"36" when 6,
	     x"37" when 7,
	     x"38" when 8,
	     x"39" when 9,
	     x"30" when others;

with (TempVal_3) select
Datas(12) <= x"30" when 0,
             x"31" when 1,
	     x"32" when 2,
	     x"33" when 3,
	     x"34" when 4,
	     x"35" when 5,
    	     x"36" when 6,
	     x"37" when 7,
	     x"38" when 8,
	     x"39" when 9,
	     x"30" when others;

Datas(11) <= x"2E";
				 
with (TempVal_4) select
Datas(10) <= x"30" when 0,
             x"31" when 1,
	     x"32" when 2,
	     x"33" when 3,
	     x"34" when 4,
	     x"35" when 5,
	     x"36" when 6,
	     x"37" when 7,
	     x"38" when 8,
	     x"39" when 9,
	     x"30" when others;
				 
Datas(15) <= x"20";
Datas(16) <= x"56";
Datas(17) <= X"C0"; --Move to Line 2--
Datas(18) <= x"41";
Datas(19) <= x"43";
Datas(20) <= x"48";
							 
with (WaveSel) select
Datas(21) <= x"30" when "000", --0--
             x"31" when "001", --1--
	     x"32" when "010", --2--
	     x"33" when "011", --3--
             x"34" when "100", --4--
 	     x"35" when "101", --5--
             x"36" when "110", --6--
	     x"37" when "111", --7--
	     x"5B" when others;		
	
LCD_proc: process(Clk)
       
       variable i : integer := 0;
       variable j : integer := 0;
       variable k : integer := 0;
     
   begin
       if (Clk'event and Clk = '1') then
          if(i <= 85000) then i := i + 1; LCD_E <= '1'; DataOut <= DataS(j)(7 downto 0);
          elsif(i > 85000 and i < 160000) then i := i + 1; lcd_e <= '0';
          elsif(i = 160000) then j := j + 1; i := 0;
          end if;

	  if(j < 4) then LCD_RS <= '0';  						  -- Command Signal --
          elsif (j >= 4 and j <= 16) then lcd_rs <= '1';   -- Data Signal -- 
	  elsif (j = 17) then lcd_rs <= '0'; 				  -- Command Signal --
	  elsif (j > 17 and j < 22) then lcd_rs <= '1';    -- Data Signal --
          end if;

	  if(j = 22) then j := 0;                -- Repeat Data Display Routine --
          end if;
       end if;
   end process LCD_proc;

end LCD_Disp_arc;
