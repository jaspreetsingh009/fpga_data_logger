library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity TX is
generic(sel  : STD_LOGIC_VECTOR(2 downto 0));
port( Clk     : IN  STD_LOGIC;
      Start   : IN  STD_LOGIC;
      TX_BUSY : OUT STD_LOGIC;
      TX_DATA : IN  STD_LOGIC_VECTOR(7 downto 0);
      TX_LINE : OUT STD_LOGIC);
end entity;

architecture TX_arc OF TX IS
 
signal PRSCL    : INTEGER RANGE 0 TO 5208 := 0;
signal INDEX    : INTEGER RANGE 0 TO 9 := 0;
signal DATAFLL  : STD_LOGIC_VECTOR(9 DOWNTO 0);
signal TX_FLG   : STD_LOGIC := '0';
signal PRSCLVal : INTEGER range 0 to 41600;

begin

with (Sel) select
PRSCLVal <= 41600 when "000",  --  1200--
            20800 when "001",  --  2400--
	    10400 when "010",  --  4800-- 
	    5200  when "011",  --  9600--
	    2600  when "100",  -- 19200--
	    1300  when "101",  -- 38400--
	    866   when "110",  -- 57600--
	    432   when "111",  --115200--
	    5200  when others; 

TX_proc: process(Clk)
begin
 if(Clk'EVENT and Clk = '1') then
   if(TX_FLG = '0' and START = '1') then 
	TX_FLG <= '1'; TX_BUSY <= '1'; DATAFLL(0) <= '0'; DATAFLL(9) <= '1'; DATAFLL(8 DOWNTO 1) <= TX_DATA;
	end if;
 
	if(TX_FLG = '1') then
	  if(PRSCL < PRSCLVal) then PRSCL <= PRSCL + 1;
	  else PRSCL <= 0;
	  end if;
 
	  if(PRSCL = PRSCLVal/2) then TX_LINE <= DATAFLL(INDEX);
		 if(INDEX < 9) then INDEX <= INDEX + 1;
		 else TX_FLG <= '0'; TX_BUSY <= '0'; INDEX <= 0;
		 end if;
	  end if;	
	end if;
 end if;
end process TX_proc;

end architecture TX_arc;
