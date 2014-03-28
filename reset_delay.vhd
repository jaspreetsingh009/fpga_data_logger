library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reset_delay IS
port ( iRSTN  : IN  STD_LOGIC;   
       iCLK   : IN  STD_LOGIC;   
       oRST   : OUT STD_LOGIC);   
end reset_delay;

architecture reset_delay_arc OF reset_delay IS

   signal cont    :  STD_LOGIC_VECTOR(20 DOWNTO 0);   
   signal oRST_T  :  STD_LOGIC;   

begin

 oRST <= oRST_T;

 rst_proc: process (iCLK,iRSTN)
  begin
    if(iRSTN = '0') then
         cont <= "000000000000000000000";    
         oRST_T <= '1';    
    elsif(rising_edge(iCLK)) then
         if (not cont(20) = '1') then
            cont <= cont + "000000000000000000001";    
            oRST_T <= '1';    
         else
            oRST_T <= '0';    
         end if;
    end if;
 end process rst_proc;

end reset_delay_arc;
