library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity spi_ee_config is
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
	   sel_axis                : IN    INTEGER range 0 to 2;
      iRSTN                   : IN    STD_LOGIC;   
      iSPI_CLK                : IN    STD_LOGIC;   
      iSPI_CLK_OUT            : IN    STD_LOGIC;   
      iG_INT2                 : IN    STD_LOGIC;   
      oDATA_L                 : OUT   STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);   
      oDATA_H                 : OUT   STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);   
      SPI_SDIO                : INOUT STD_LOGIC;   
      oSPI_CSN                : OUT   STD_LOGIC;   
      oSPI_CLK                : OUT   STD_LOGIC);   
end spi_ee_config;

architecture spi_ee_config_arc of spi_ee_config is

   component spi_controller
      generic (
          X_LB                :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110010";    
          Z_HB                :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110111";    
         -- Data MSB Bit
         -- Initial Reg Number 
          Y_LB                :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110100";    
          READ_MODE           :  STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";    
          Z_LB                :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110110";    
          SI_DataL            :  INTEGER := 15;    
          THRESH_ACT          :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "100100";    
          THRESH_INACT        :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "100101";    
          POWER_CONTROL       :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101101";    
          SO_DataL            :  INTEGER := 7;    
          INT_ENABLE          :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101110";    
          THRESH_FF           :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101000";    
         -- SPI State 
          TIME_FF             :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101001";    
          TIME_INACT          :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "100110";    
          TRANSFER            :  STD_LOGIC := '1';    
          ACT_INACT_CTL       :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "100111";    
          DATA_FORMAT         :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110001";    
          X_HB                :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110011";    
         -- Write/Read Mode 
         -- Read Reg Address
         -- Write Reg Address 
          INT_MAP             :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "101111";    
          Y_HB                :  STD_LOGIC_VECTOR(5 DOWNTO 0) := "110101");    
      port (
         iRSTN                : IN    STD_LOGIC;
         iSPI_CLK             : IN    STD_LOGIC;
         iSPI_CLK_OUT         : IN    STD_LOGIC;
         iP2S_DATA            : IN    STD_LOGIC_VECTOR(SI_DataL DOWNTO 0);
         iSPI_GO              : IN    STD_LOGIC;
         oSPI_END             : OUT   STD_LOGIC;
         oS2P_DATA            : OUT   STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);
         SPI_SDIO             : INOUT STD_LOGIC;
         oSPI_CSN             : OUT   STD_LOGIC;
         oSPI_CLK             : OUT   STD_LOGIC);
   end component;

   signal ini_index                :  STD_LOGIC_VECTOR(3 DOWNTO 0);   
   signal write_data               :  STD_LOGIC_VECTOR(SI_DataL - 2 DOWNTO 0);   
   signal p2s_data                 :  STD_LOGIC_VECTOR(SI_DataL DOWNTO 0);   
   signal spi_go                   :  STD_LOGIC;   
   signal spi_end                  :  STD_LOGIC;   
   signal s2p_data                 :  STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);   
   signal low_byte_data            :  STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);   
   signal spi_state                :  STD_LOGIC;   
   signal high_byte                :  STD_LOGIC;   
   signal read_back                :  STD_LOGIC;   
   signal clear_status             :  STD_LOGIC;   
   signal read_ready               :  STD_LOGIC;   
   signal clear_status_d           :  STD_LOGIC_VECTOR(3 DOWNTO 0);   
   signal high_byte_d              :  STD_LOGIC;   
   signal read_back_d              :  STD_LOGIC;   
   signal read_idle_count          :  STD_LOGIC_VECTOR(IDLE_MSB DOWNTO 0);   
   signal oDATA_L_xhdl1            :  STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);   
   signal oDATA_H_xhdl2            :  STD_LOGIC_VECTOR(SO_DataL DOWNTO 0);   
   signal oSPI_CSN_xhdl3           :  STD_LOGIC;   
   signal oSPI_CLK_xhdl4           :  STD_LOGIC;

begin
	
   oDATA_L <= oDATA_L_xhdl1;
   oDATA_H <= oDATA_H_xhdl2;
   oSPI_CSN <= oSPI_CSN_xhdl3;
   oSPI_CLK <= oSPI_CLK_xhdl4;
   
	u_spi_controller : spi_controller 
   port map ( iRSTN => iRSTN,
              iSPI_CLK => iSPI_CLK,
              iSPI_CLK_OUT => iSPI_CLK_OUT,
              iP2S_DATA => p2s_data,
              iSPI_GO => spi_go,
              oSPI_END => spi_end,
              oS2P_DATA => s2p_data,
              SPI_SDIO => SPI_SDIO,
              oSPI_CSN => oSPI_CSN_xhdl3,
              oSPI_CLK => oSPI_CLK_xhdl4 );   
   
   process (ini_index)
   begin
      case ini_index is
         when "0000" =>
                  write_data <= THRESH_ACT & "00100000";    
         when "0001" =>
                  write_data <= THRESH_INACT & "00000011";    
         when "0010" =>
                  write_data <= TIME_INACT & "00000001";    
         when "0011" =>
                  write_data <= ACT_INACT_CTL & "01111111";    
         when "0100" =>
                  write_data <= THRESH_FF & "00001001";    
         when "0101" =>
                  write_data <= TIME_FF & "01000110";    
         when "0110" =>
                  write_data <= BW_RATE & "00001001";    
         when "0111" =>
                  write_data <= INT_ENABLE & "00010000";    
         when "1000" =>
                  write_data <= INT_MAP & "00010000";    
         when "1001" =>
                  write_data <= DATA_FORMAT & "01000000";    
         when others  =>
                  write_data <= POWER_CONTROL & "00001000";    
         
      end case;
   end process;

   process (iRSTN, iSPI_CLK, sel_axis)
   begin
      if (iRSTN = '0') then
         ini_index <= "0000";    
         spi_go <= '0';    
         spi_state <= IDLE;    
         read_idle_count <= (OTHERS => '0');    
         high_byte <= '0';    
         read_back <= '0';    
         clear_status <= '0';    
      elsif rising_edge(iSPI_CLK) then
         if (ini_index < INI_NUMBER) then
            case spi_state IS
               when IDLE =>
                        p2s_data <= WRITE_MODE & write_data;    
                        spi_go <= '1';    
                        spi_state <= TRANSFER;    
               when TRANSFER =>
                        if (spi_end = '1') then
                           ini_index <= ini_index + "0001";    
                           spi_go <= '0';    
                           spi_state <= IDLE;    
                        end if;
               when others =>
                         NULL;
               
            end case;
         else
            case spi_state is
               when IDLE =>
                        read_idle_count <= read_idle_count + "000000000000001";    
                        if (high_byte = '1') then
			   if(sel_axis = 0) then
					p2s_data(15 DOWNTO 8) <= READ_MODE & X_HB;    
				elsif(sel_axis = 1) then
					p2s_data(15 DOWNTO 8) <= READ_MODE & Y_HB; 
				elsif(sel_axis = 2) then
					p2s_data(15 DOWNTO 8) <= READ_MODE & Z_HB; 
				end if;
                           read_back <= '1';    
                        else
                           if (read_ready = '1') then
                              if(sel_axis = 0) then
					p2s_data(15 DOWNTO 8) <= READ_MODE & X_LB;    
			      elsif(sel_axis = 1) then
					p2s_data(15 DOWNTO 8) <= READ_MODE & Y_LB; 
			      elsif(sel_axis = 2) then
					p2s_data(15 DOWNTO 8) <= READ_MODE & Z_LB; 
			      end if;
                           read_back <= '1';    
                           else
                              if (((NOT clear_status_d(3) AND iG_INT2) OR read_idle_count(IDLE_MSB)) = '1') then
                                 p2s_data(15 DOWNTO 8) <= READ_MODE & INT_SOURCE;    
                                 clear_status <= '1';    
                              end if;
                           end if;
                        end if;
                        if ((high_byte OR read_ready OR read_idle_count(IDLE_MSB) OR (NOT clear_status_d(3) AND iG_INT2)) = '1') THEN
                           spi_go <= '1';    
                           spi_state <= TRANSFER;    
                        end if;
                        if (read_back_d = '1') then
                           if (high_byte_d = '1') then
                              oDATA_H_xhdl2 <= s2p_data;    
                              oDATA_L_xhdl1 <= low_byte_data;    
                           else
                              low_byte_data <= s2p_data;    
                           end if;
                        end if;
               when TRANSFER =>
                        if (spi_end = '1') then
                           spi_go <= '0';    
                           spi_state <= IDLE;    
                           if (read_back = '1') then
                              read_back <= '0';    
                              high_byte <= NOT high_byte;    
                              read_ready <= '0';    
                           else
                              clear_status <= '0';    
                              read_ready <= s2p_data(6);    
                              read_idle_count <= (OTHERS => '0');    
                           end if;
                        end if;
               when others =>
                        NULL;
               
            end case;
         end if;
      end if;
   end process;

   process(iRSTN, iSPI_CLK)
   begin
      if(iRSTN = '0') then
         high_byte_d <= '0';    
         read_back_d <= '0';    
         clear_status_d <= "0000";    
      elsif(rising_edge(iSPI_CLK)) then
         high_byte_d <= high_byte;    
         read_back_d <= read_back;    
         clear_status_d <= clear_status_d(2 DOWNTO 0) & clear_status;    
      end if;
   end process;

end spi_ee_config_arc;
