library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RX is
generic(sel  : STD_LOGIC_VECTOR(2 downto 0));
port(Clk     : IN  STD_LOGIC;
     RX_LINE : IN  STD_LOGIC;
     RX_DATA : OUT STD_LOGIC_VECTOR(7 downto 0);
     RX_BUSY : OUT STD_LOGIC);
end entity;
 
architecture RX_arc OF RX IS
signal DATAFLL: STD_LOGIC_VECTOR(9 downto 0);
signal RX_FLG: STD_LOGIC := '0';
signal PRSCL: INTEGER RANGE 0 TO 5208 := 0;
signal INDEX: INTEGER RANGE 0  TO 9 := 0;
signal PRSCLVal: INTEGER range 0 to 41600;

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

rx_proc: process(Clk)
begin
 if(Clk'EVENT and Clk = '1') then
   if(RX_FLG = '0' and RX_LINE = '0') then INDEX <= 0; PRSCL <= 0; RX_BUSY <= '1'; RX_FLG <= '1';
	end if;
 
   if(RX_FLG = '1') then DATAFLL(INDEX) <= RX_LINE;
	  if(PRSCL < PRSCLVal) then PRSCL <= PRSCL + 1;
	  else PRSCL <= 0;
	  end if;
	  
	  if(PRSCL = PRSCLVal/2) then
		 if(INDEX < 9) then INDEX <= INDEX + 1;
		 else
			if(DATAFLL(0) = '0' and DATAFLL(9)= '1') then RX_DATA <= DATAFLL(8 DOWNTO 1);
			else RX_DATA <= "00000000";
			end if;
			 
		 RX_FLG <= '0'; RX_BUSY <= '0';
		 end if;
	  end if;  
   end if;
 end if;
end process rx_proc;

end architecture RX_arc;
