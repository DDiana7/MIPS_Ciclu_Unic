----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2025 06:37:30 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
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

entity MEM is
port ( 
        clk           : in std_logic;
        mw            : in std_logic;  
        en            : in std_logic;
        ALUResultIn   : in std_logic_vector(31 downto 0);
        RD2           : in std_logic_vector(31 downto 0);
        MemData       : out std_logic_vector(31 downto 0);
        ALUResultOut  : out std_logic_vector(31 downto 0));
end MEM;


architecture Behavioral of MEM is
    type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal mem : ram_type := (
        1 => X"00000004", -- Numarul de elemente din vector
        2 => X"00000001", -- 1
        3 => X"FFFFFFFF", -- -1
        4 => X"00000002", -- 2
        5 => X"00000004", -- 4
        others => X"00000000"
    );
    
begin

    --Scriere sincrona cu activare enable
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and mw = '1' then
                 mem(conv_integer(ALUResultIn(7 downto 2))) <= RD2;
            end if;
        end if;
    end process;
    
    --Citire asincrona
    MemData <= mem(conv_integer(ALUResultIn(7 downto 2)));

    ALUResultOut <= ALUResultIn;

end Behavioral;
