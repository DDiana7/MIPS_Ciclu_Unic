----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2025 07:08:21 PM
-- Design Name: 
-- Module Name: UC - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UC is
    Port ( Instr : in STD_LOGIC_VECTOR (5 downto 0);
    RegDst: out STD_LOGIC;
    ExtOp: out STD_LOGIC;
    ALUSrc: out STD_LOGIC;
    Branch: out STD_LOGIC;
    Jump: out STD_LOGIC;
    ALUOp: out STD_LOGIC_VECTOR (2 downto 0);
    MemWrite: out STD_LOGIC;
    MemtoReg: out STD_LOGIC;
    RegWrite: out STD_LOGIC;
    Br_GTZ: out STD_LOGIC);
end UC;

architecture Behavioral of UC is
begin
    process(Instr)
    begin
        --Setam totul initial pe 0
        RegDst <= '0';
        ExtOp <= '0';
        ALUSrc <= '0';
        Branch <= '0';
        Jump <= '0';
        ALUOp <= "000";
        MemWrite <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';
        Br_GTZ <= '0';

        case Instr is
             when "000000" =>  -- Toate R-type (ADD, SUB, SLL, SRL, AND, OR, SLLV, SLT)
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "000"; 

          when "001000" =>  -- ADDI
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "001"; -- ADD
                
            when "100011" =>  -- LW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp <= "001"; -- ADD pentru adresa

            when "101011" =>  -- SW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';
                ALUOp <= "001"; -- ADD pentru adresa

            when "000100" =>  -- BEQ
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "010"; -- SUB pentru comparare
                Jump <= '0';

            when "000111" =>  -- BGTZ
                ExtOp <= '1';
                Br_GTZ <= '1';
                ALUOp <= "010"; -- SUB pentru comparare
                Jump <= '0';

            when "001010" =>  -- SLTI
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "011"; -- SLT

            when "001100" =>  -- ANDI
                ALUSrc <= '1';     
                RegWrite <= '1';   
                ALUOp <= "100";    

            when "000010" =>  -- J 
                Jump <= '1';
                
            when others => null;
        end case;
    end process;
end Behavioral;
