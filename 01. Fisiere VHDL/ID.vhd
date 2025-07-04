----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2025 06:40:31 PM
-- Design Name: 
-- Module Name: ID - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID is
    Port ( clk: in STD_LOGIC;
           RegWrite : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (25 downto 0);
           RegDst : in STD_LOGIC;
           EN : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR (31 downto 0);
           func : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0));
end ID;

architecture Behavioral of ID is

    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal reg_file : reg_array:=  (others => X"00000000");
    signal wa: STD_LOGIC_VECTOR (4 downto 0);
    
begin
    wa <= (Instr(20 downto 16)) when RegDst = '0' else (Instr(15 downto 11));
    
    process(clk)
    begin
        if rising_edge(clk) then
            if RegWrite = '1' and EN = '1' then
                reg_file(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process;
    
    RD1 <= reg_file(conv_integer(Instr(25 downto 21)));
    RD2 <= reg_file(conv_integer(Instr(20 downto 16)));
    
    func <= Instr(5 downto 0);
    sa <= Instr(10 downto 6);
    
    Ext_Imm(15 downto 0) <= Instr(15 downto 0);
    Ext_Imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else (others => '0');

end Behavioral;
