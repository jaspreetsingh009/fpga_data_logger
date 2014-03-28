library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity fpgalogger is
port( Clk     			  :  IN    STD_LOGIC;
		  WaveSel         :  IN    STD_LOGIC_VECTOR(2 downto 0);
	    LCD_RS          :  OUT   STD_LOGIC;
		  LCD_E           :  OUT   STD_LOGIC;
		  TX_BUSY 			  :  OUT   STD_LOGIC;
		  RX_BUSY 			  :  OUT   STD_LOGIC;		
		  RX_DATA 			  :  OUT   STD_LOGIC_VECTOR(7 downto 0);
		  LCD_DataOut     :  OUT   STD_LOGIC_VECTOR(7 downto 0);
		  RX_LINE 			  :  IN    STD_LOGIC;
	    TX_LINE			    :  OUT   STD_LOGIC;
		  iGO     			  :  IN    STD_LOGIC := '0';
		  RST_GS          :  IN    STD_LOGIC;
      G_SENSOR_CS_N   :  OUT   STD_LOGIC;
      G_SENSOR_INT    :  IN    STD_LOGIC;
      I2C_SCLK        :  OUT   STD_LOGIC;
      I2C_SDAT        :  INOUT STD_LOGIC;
		  oDIN    			  :  OUT   STD_LOGIC;
		  oCS_n   			  :  OUT   STD_LOGIC;
		  oSCLK   			  :  OUT   STD_LOGIC;
		  iDOUT   			  :  IN    STD_LOGIC);
end UARTModuleT;

architecture fpgalogger_arc of fpgalogger is

signal Start_EN 		  :  STD_LOGIC;
signal count    		  :  INTEGER := 0;
signal TX_DATA  		  :  STD_LOGIC_VECTOR(7 downto 0);
signal PRSCLVal 		  :  INTEGER range 0 to 41600;
signal ADCOut   		  :  STD_LOGIC_VECTOR(11 downto 0);
signal OutCkt   		  :  STD_LOGIC_VECTOR(11 downto 0);
signal DataOut  		  :  INTEGER range 0 to 4095;
signal Dout     		  :  STD_LOGIC_VECTOR(2 downto 0);
signal sel_axis 		  :  INTEGER range 0 to 2;
signal G_SENSOR_OUT_T :  STD_LOGIC_VECTOR(9 downto 0);
signal LCD_Data_T     :  STD_LOGIC_VECTOR(11 downto 0);

begin

		DataOut <= to_integer(UNSIGNED(OutCkt));

		GS1 : entity work.Control_Unit
			generic map( countVal =>   70000 )
			port map( Clk  	   =>   Clk,
						 Flag	 	     =>   Start_EN,
					 	 DataOut     =>   DataOut,
						 GSDataOut   =>   G_SENSOR_OUT_T,
						 TX_Data     =>   TX_DATA,
						 sel_axis    =>   sel_axis,
						 Dout        =>   Dout,
						 WaveSel     =>   WaveSel,
						 LCD_Data_T  =>   LCD_Data_T );

		AD1 : entity work.ADCModule
			port map( Clk    	    =>   Clk,
				   	    iGO   	    =>   iGO,
					      oDIN        =>   oDIN,
						    oCS_n  	    =>   oCS_n,
						    oSCLK  	    =>   oSCLK,
						    iDOUT  	    =>   iDOUT,
						    iCH    	    =>   Dout,
						    OutCkt 	    =>   OutCkt ); 

		RX1 : entity work.RX
			generic map( sel      =>   "011" )
			port map( Clk         =>   Clk,
						    RX_LINE     =>   RX_LINE,
						    RX_DATA     =>   RX_DATA,
						    RX_BUSY     =>   RX_BUSY );

		TX1 : entity work.TX
			generic map( sel      =>   "011")
			port map( Clk         =>   Clk,
						    Start       =>   Start_EN,
						    TX_BUSY     =>   TX_BUSY,
						    TX_DATA     =>   TX_DATA,
						    TX_LINE     =>   TX_LINE );
						 
		LCDModule: entity work.LCD_Disp
			port map( Clk         =>   Clk,
						    LCD_RS      =>   LCD_RS,
						    LCD_E       =>   LCD_E,	
						    LCD_Data    =>   LCD_Data_T,
						    WaveSel     =>   WaveSel,
						    DataOut     =>   LCD_DataOut);

		GSensor: entity work.accelerometer 
			port map( Clk              =>   Clk,
						    sel_axis         =>   sel_axis,
						    KEY              =>   RST_GS,
				   	    G_SENSOR_CS_N    =>   G_SENSOR_CS_N,
					      G_SENSOR_INT     =>   G_SENSOR_INT,
						    I2C_SCLK         =>   I2C_SCLK,
						    G_SENSOR_OUT     =>   G_SENSOR_OUT_T,
						    I2C_SDAT         =>   I2C_SDAT );

end architecture fpgalogger_arc;
