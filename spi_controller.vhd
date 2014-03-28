library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

entity spi_controller is
   generic (
      -- Data MSB Bit
      IDLE_MSB                :  INTEGER := 14;    
      SI_DataL                :  INTEGER := 15;    
      SO_DataL                :  INTEGER := 7;    
      -- Write/Read Mode 
      WRITE_MODE              :  STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";    
      READ_MODE               :  STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";    
      -- Initial Reg Number 
      INI_NUMBER              :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";    
      -- SPI State 
      IDLE                    :  STD_LOGIC := '0';    
      TRANSFER                :  STD_LOGIC := '1';    
      -- Write Reg Address 
      BW_RATE                 :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101100";    
      POWER_CONTROL           :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101101";    
      DATA_FORMAT             :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110001";    
      INT_ENABLE              :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101110";    
      INT_MAP                 :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101111";    
      THRESH_ACT              :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "100100";    
      THRESH_INACT            :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "100101";    
      TIME_INACT              :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "100110";    
      ACT_INACT_CTL           :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "100111";    
      THRESH_FF               :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101000";    
      TIME_FF                 :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101001";    
      -- Read Reg Address
      INT_SOURCE              :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110000";    
      X_LB                    :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110010";    
      X_HB                    :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110011";    
      Y_LB                    :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110100";    
      Y_HB                    :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110101";    
      Z_LB                    :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110110";    
      Z_HB                    :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110111");    
   port (
      iRSTN                   : IN    STD_LOGIC;   
      iSPI_CLK                : IN    STD_LOGIC;   
      iSPI_CLK_OUT            : IN    STD_LOGIC;   
      iP2S_DATA               : IN    STD_LOGIC_VECTOR(SI_DataL DOWNTO 0);   
      iSPI_GO                 : IN    STD_LOGIC;   
      oSPI_END                : OUT   STD_LOGIC;   
      oS2P_DATA               : OUT   STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);   
      SPI_SDIO                : INOUT STD_LOGIC;   
      oSPI_CSN                : OUT   STD_LOGIC;   
      oSPI_CLK                : OUT   STD_LOGIC);   
end spi_controller;

architecture spi_controller_arc of spi_controller is

   signal read_mode_xhdl5          :  STD_LOGIC;   
   signal write_address            :  STD_LOGIC;   
   signal spi_count_en             :  STD_LOGIC;   
   signal spi_count                :  STD_LOGIC_VECTOR(3 DOWNTO 0);   
   signal temp_xhdl6               :  STD_LOGIC;   
   signal temp_xhdl7               :  STD_LOGIC;   
   signal oSPI_END_xhdl1           :  STD_LOGIC;   
   signal oS2P_DATA_xhdl2          :  STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);   
   signal oSPI_CSN_xhdl3           :  STD_LOGIC;   
   signal oSPI_CLK_xhdl4           :  STD_LOGIC;   

begin
   oSPI_END <= oSPI_END_xhdl1;
   oS2P_DATA <= oS2P_DATA_xhdl2;
   oSPI_CSN <= oSPI_CSN_xhdl3;
   oSPI_CLK <= oSPI_CLK_xhdl4;
   read_mode_xhdl5 <= iP2S_DATA(SI_DataL) ;
   write_address <= spi_count(3) ;
   oSPI_END_xhdl1 <= NOR_REDUCE(spi_count) ;
   oSPI_CSN_xhdl3 <= NOT iSPI_GO ;
   temp_xhdl6 <= iSPI_CLK_OUT when spi_count_en = '1' else '1';
   oSPI_CLK_xhdl4 <= temp_xhdl6 ;
   temp_xhdl7 <= iP2S_DATA(conv_integer(spi_count)) when (spi_count_en AND (NOT read_mode_xhdl5 OR write_address)) = '1' else 'Z';
   SPI_SDIO <= temp_xhdl7 ;

   process (iRSTN, iSPI_CLK)
   begin
      if (iRSTN = '0') THEN
         spi_count_en <= '0';    
         spi_count <= "1111";    
      elsif rising_edge(iSPI_CLK) then
         if (oSPI_END_xhdl1 = '1') then
            spi_count_en <= '0';    
         else
            if (iSPI_GO = '1') then
               spi_count_en <= '1';    
            end if;
         end if;
         if(NOT spi_count_en = '1') then
            spi_count <= "1111";    
         else
            spi_count <= spi_count - "0001";    
         end if;
         if((read_mode_xhdl5 AND NOT write_address) = '1') then
            oS2P_DATA_xhdl2 <= oS2P_DATA_xhdl2(SO_DataL - 1 downto 0) & SPI_SDIO;    
         end if;
      end if;
   end process;

end spi_controller_arc;
