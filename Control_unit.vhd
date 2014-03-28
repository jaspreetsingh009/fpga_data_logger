library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit is
generic (countVal  :  INTEGER );
port( Clk  		    :  IN  STD_LOGIC;
      Flag	 	    :  OUT STD_LOGIC;
	   DataOut      :  IN  INTEGER range 0 to 4095;
	   GSDataOut    :  IN  STD_LOGIC_VECTOR(9 downto 0);
	   TX_Data      :  OUT STD_LOGIC_VECTOR(7 downto 0);
	   sel_axis     :  OUT INTEGER range 0 to 2;
	   Dout         :  OUT STD_LOGIC_VECTOR(2 downto 0);
	   WaveSel      :  IN  STD_LOGIC_VECTOR(2 downto 0);
	   LCD_Data_T   :  OUT STD_LOGIC_VECTOR(11 downto 0) );
end entity;

architecture Control_Unit_arc of Control_Unit is

signal count 				:  INTEGER := 0;
signal sel_axis_t			:  INTEGER range 0  to 2;
signal i 					:  INTEGER range 0 to 5;
signal datacount			:  INTEGER range 0 to 8 := 0;
signal data_acquire		:  STD_LOGIC := '0';
signal Dtemp 				:  STD_LOGIC_VECTOR(2 downto 0);
signal Data_EndChar		:  STD_LOGIC_VECTOR(7 downto 0);
signal Data_EndChar_1	:  STD_LOGIC_VECTOR(7 downto 0);
signal GSDataOut1 		:  STD_LOGIC_VECTOR(7 downto 0);
signal GSDataOut2 		:  INTEGER range 0 to 255;
signal DataOut_STD_L    :  STD_LOGIC_VECTOR(11 downto 0);

begin

DataOut_STD_L <= STD_LOGIC_VECTOR(to_unsigned(DataOut, 12));
	
LCD_Data_proc : process(Clk)
begin
	if(rising_edge(Clk)) then
		 case (WaveSel) is
				when "000"  => if(datacount = 0) then LCD_Data_T <= DataOut_STD_L;
								   end if;
				when "001"  => if(datacount = 1) then LCD_Data_T <= DataOut_STD_L;
								   end if;
				when "010"  => if(datacount = 2) then LCD_Data_T <= DataOut_STD_L;
								   end if;
				when "011"  => if(datacount = 3) then LCD_Data_T <= DataOut_STD_L;
								   end if;
				when "100"  => if(datacount = 4) then LCD_Data_T <= DataOut_STD_L;
								   end if;
				when "101"  => if(datacount = 5) then LCD_Data_T <= DataOut_STD_L;
								   end if;
				when "110"  => if(datacount = 6) then LCD_Data_T <= DataOut_STD_L;
								   end if;
				when "111"  => if(datacount = 7) then LCD_Data_T <= DataOut_STD_L;
								   end if;
				when others => LCD_Data_T <= "000000000000";
		end case;
	end if;
end process LCD_Data_proc;

sel_axis <=	sel_axis_t;

delay_proc: process(Clk)

variable Dtemp1: INTEGER range 0 to 4095;
variable Dtemp2: INTEGER range 0 to 4095;
variable Dtemp3: INTEGER range 0 to 4095;
type arrayData is array (0 to 5) of STD_LOGIC_VECTOR(7 downto 0);
variable Datas : arrayData := (X"30", X"30", X"30", X"30", X"41", X"0a");

begin
  if(rising_edge(Clk)) then
     if(data_acquire = '1') then 
	  
		 if(datacount < 8) then
			Datas(4) := Data_EndChar;
			Datas(3) := STD_LOGIC_VECTOR(to_unsigned(DataOut mod 10, 8) + X"30" ); Dtemp1 := DataOut/10;
			Datas(2) := STD_LOGIC_VECTOR(to_unsigned(Dtemp1  mod 10, 8) + X"30" ); Dtemp2 := DataOut/100;
			Datas(1) := STD_LOGIC_VECTOR(to_unsigned(Dtemp2  mod 10, 8) + X"30" ); Dtemp3 := DataOut/1000;
			Datas(0) := STD_LOGIC_VECTOR(to_unsigned(Dtemp3  mod 10, 8) + X"30" ); 
			
		 elsif(datacount = 8) then
		   GSDataOut1 <= GSDataOut(7 downto 0);
			GSDataOut2 <= to_integer(UNSIGNED(GSDataOut1));
		   Datas(4) := Data_EndChar_1;
			Datas(3) := STD_LOGIC_VECTOR(to_unsigned(GSDataOut2 mod 10, 8) + X"30" ); Dtemp1 := GSDataOut2/10;
			Datas(2) := STD_LOGIC_VECTOR(to_unsigned(Dtemp1 mod 10, 8) + X"30" ); Dtemp2 := GSDataOut2/100;
			Datas(1) := STD_LOGIC_VECTOR(to_unsigned(Dtemp2 mod 10, 8) + X"30" );
			
			if(GSDataOut(9) = '1') then Datas(0) := X"2D";
			else Datas(0) := X"2B";
			end if;
			
		 end if;
		end if;
	  if(count = countVal) then Flag <= '1'; count <= 0; TX_Data <= Datas(i); data_acquire <= '0';
		  if(i = 5) then i <= 0; data_acquire <= '1'; 
			  if(datacount < 8) then 
						Dtemp <= STD_LOGIC_VECTOR(UNSIGNED(Dtemp) + 1);
						datacount <= datacount + 1;
			  elsif(datacount = 8) then
			         datacount <= 0;
						sel_axis_t <= sel_axis_t + 1;
			  end if;
		  else i <= i + 1;
		  end if;
	  else count <= count + 1; Flag <= '0';
	  end if;
  end if;
end process delay_proc;

Dout <= Dtemp;

with (sel_axis_t) select
Data_EndChar_1 <= X"49" when 0,
						X"4A" when 1,
						X"4B" when 2,
						X"4C" when others;

with (Dtemp) select
Data_EndChar <= X"41" when "000",
                X"42" when "001",
					 X"43" when "010",
					 X"44" when "011",
					 X"45" when "100",
					 X"46" when "101",
					 X"47" when "110",
					 X"48" when "111",
					 X"4D" when others;

end architecture Control_Unit_arc;
