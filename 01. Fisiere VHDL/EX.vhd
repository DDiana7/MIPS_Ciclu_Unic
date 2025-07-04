----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2025 06:51:29 PM
-- Design Name: 
-- Module Name: EX - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EX is
port ( 
    rd1 : in std_logic_vector(31 downto 0);
    ALUSrc : in std_logic;
    rd2 : in std_logic_vector(31 downto 0);
    Ext_imm : in std_logic_vector(31 downto 0);
    sa : in std_logic_vector(4 downto 0);
    func : in std_logic_vector(5 downto 0);
    ALUOp : in std_logic_vector(2 downto 0);
    pcp : in std_logic_vector(31 downto 0);
    gtz : out std_logic;
    zero : out std_logic;
    ALURes : out std_logic_vector(31 downto 0);
    badd : out std_logic_vector(31 downto 0));
end EX;

architecture Behavioral of EX is
    signal A, B, C : std_logic_vector(31 downto 0);
    signal ALUCtrl : std_logic_vector(3 downto 0);
begin

    B <= rd2 when ALUSrc = '0' else Ext_imm;
    A <= rd1;
    badd <= pcp + (Ext_Imm(29 downto 0) & "00"); 

    process(ALUOp, func)
    begin
        case ALUOp is
            when "000" => -- R-type
                case func is
                    when "100000" => ALUCtrl <= "0000"; -- ADD
                    when "100010" => ALUCtrl <= "0001"; -- SUB
                    when "000000" => ALUCtrl <= "0010"; -- SLL
                    when "000010" => ALUCtrl <= "0011"; -- SRL
                    when "100100" => ALUCtrl <= "0100"; -- AND
                    when "100101" => ALUCtrl <= "0101"; -- OR
                    when "000100" => ALUCtrl <= "0110"; -- SLLV
                    when "101010" => ALUCtrl <= "0111"; -- SLT
                    when others   => ALUCtrl <= "1111";
                end case;
            when "001" => ALUCtrl <= "0000"; -- ADD (LW, SW, ADDI)
            when "010" => ALUCtrl <= "0001"; -- SUB (BEQ, BGTZ)
            when "011" => ALUCtrl <= "0111"; -- SLTI
            when "100" => ALUCtrl <= "0100"; -- ANDI 
            when others => ALUCtrl <= "1111";
        end case;
    end process;

    process(A, B, ALUCtrl, sa)
    begin
        case ALUCtrl is
            when "0000" => C <= A + B; -- ADD
            when "0001" => C <= A - B; -- SUB
            when "0010" => C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa)); -- SLL
            when "0011" => C <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa)); -- SRL
            when "0100" => C <= A and B; -- AND
            when "0101" => C <= A or B;  -- OR
            when "0110" => C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(A(4 downto 0))); -- SLLV
            when "0111" => -- SLT
                if signed(A) < signed(B) then
                    C <= X"00000001";
                else
                    C <= X"00000000";
                end if;
            when others => C <= (others => 'X');
        end case;
    end process;

    ALURes <= C;
    zero <= '1' when C = X"00000000" else '0';
    gtz <= '1' when (C(31) = '0' and C /= X"00000000") else '0';

end Behavioral;
