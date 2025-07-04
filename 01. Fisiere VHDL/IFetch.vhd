----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2025 06:32:51 PM
-- Design Name: 
-- Module Name: IFetch - Behavioral
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

entity IFetch is
    Port ( Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           Enable : in STD_LOGIC;
           Reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           PCPlus : out STD_LOGIC_VECTOR (31 downto 0);
           Instruction : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

signal PC: STD_LOGIC_VECTOR(31 downto 0);
signal PC_plus: STD_LOGIC_VECTOR(31 downto 0);
signal PC_branch: STD_LOGIC_VECTOR(31 downto 0);
signal PC_next: STD_LOGIC_VECTOR(31 downto 0);

type ROM_array is array(0 to 31) of std_logic_vector(31 downto 0);
signal mem: ROM_array := (
    --Numarul de numere pozitive si pare dintr-un sir
    0  => B"000000_00000_00000_01000_00000_100000", 
    -- Hexa: 0x00004020
    -- Pozitie: 0x00000004
    -- Assembly: add $8, $zero, $zero 
    -- Ce face: Initializeaza contorul ($8) cu 0
    1  => B"100011_00000_01001_0000000000000100", 
    -- Hexa: 0x8C090004
    -- Pozitie: 0x00000008
    -- Assembly: lw $9, 4($zero) 
    -- Ce face: Citeste lungimea vectorului din memorie
    2  => B"000000_00000_00000_01010_00000_100000", 
    -- Hexa: 0x00005020
    -- Pozitie: 0x0000000c
    -- Assembly: add $10, $zero, $zero
    -- Ce face: Initializeaza indexul pentru parcurgere ($10) cu 0
    3  => B"001000_00000_01011_0000000000001000", 
    -- Hexa: 0x200B0008
    -- Pozitie: 0x00000010
    -- Assembly: addi $11, $zero, 8
    -- Ce face: Salveaza adresa de start a vectorului (offset 8)
    4  => B"000100_01010_01001_0000000000001011", 
    -- Hexa: 0x1149000B
    -- Pozitie: 0x00000014
    -- Assembly: beq $10, $9, end (offset=11)
    -- Ce face: Daca indexul a ajuns la dimensiunea vectorului, merge la final
    5  => B"000000_00000_01010_01100_00010_000000", 
    -- Hexa: 0x000A6020
    -- Pozitie: 0x00000018
    -- Assembly: sll $12, $10, 2 
    -- Ce face: Calculam in $12 offsetul la care se afla elementul fata de origine
    6  => B"000000_01011_01100_01101_00000_100000", 
    -- Hexa: 0x016C6820
    -- Pozitie: 0x0000001c
    -- Assembly: add $13, $11, $12
    -- Ce face: Aflam adresa din memorie a elementului 
    7  => B"100011_01101_01110_0000000000000000", 
    -- Hexa: 0x8DAE0000
    -- Pozitie: 0x00000020
    -- Assembly: lw $14, $13
    -- Ce face: Ia valoarea elementului din memorie
    8  => B"000111_01110_00000_0000000000000001", --  -- 
    -- Hexa: 0x1D800001
    -- Pozitie: 0x00000024
    -- Assembly: bgtz $14, check_even (offset=1)
    -- Ce face: Verificam daca numarul e pozitiv, daca da, sare peste jump
    9  => B"000010_00000_00000_0000000000001110",  
    -- Hexa: 0x0800000E
    -- Pozitie: 0x00000028
    -- Assembly: j next (addr = 14 / 4 = 3)
    -- Ce face: Daca e negativ, trece la urmatorul numar
    10 => B"001100_01110_01111_0000000000000001",
    -- Hexa: 0x38EF0001
    -- Pozitie: 0x0000002c
    -- Assembly: andi $15, $14, 1
    -- Ce face: Verificam bitul cel mai putin semnificativ pentru paritate
    11 => B"001010_01111_11000_0000000000000001", 
    -- Hexa: 0x29F80001
    -- Pozitie: 0x00000030
    -- Assembly: slti $24, $15, 1
    -- Ce face: Inversam rezultatul, astfel ca avem in registrul $24 1 daca numarul e par, 0 in caz contrar
    12 => B"000100_11000_00000_0000000000000001", 
    -- Hexa: 0x13000001
    -- Pozitie: 0x00000034
    -- Assembly: beq $24, $zero, next (off=1)
    -- Ce face: Daca $24 e 0, numarul e  impar, incrementam doar indexul, nu si contorul
    13 => B"001000_01000_01000_0000000000000001", 
    -- Hexa: 0x21080001
    -- Pozitie: 0x00000038
    -- Assembly: addi $8, $8, 1 
    -- Ce face: Daca e par, incrementam contorul
    14 => B"001000_01010_01010_0000000000000001", 
    -- Hexa: 0x214A0001
    -- Pozitie: 0x0000003c
    -- Assembly: addi $10, $10, 1  
    -- Ce face: Incrementam indexul
    15 => B"000010_00000_00000_0000000000000100",
    -- Hexa: 0x08000004
    -- Pozitie: 0x00000040
    -- Assembly: j loop (addr = 4 / 4 = 1)
    -- Ce face: Revine la inceputul buclei
    16 => B"101011_00000_01000_0000000000000000", 
    -- Hexa: 0xAC080000
    -- Pozitie: 0x00000044
    -- Assembly: sw $8, 0($zero)
    -- Ce face: Cand bucla e gata, salvam counterul
    others => X"00000000"
);


begin

    PC_plus <= PC + 4;

    --Mux 1 pt branch
    PC_branch <= BranchAddress when PCSrc = '1' else PC_plus;

    --Mux 2 pt jump
    PC_next <= JumpAddress when Jump = '1' else PC_branch;

    process(clk,Reset)
    begin
        if Reset = '1' then
           PC<=(others => '0');
        elsif rising_edge(clk) then
           if Enable = '1' then
               PC<=PC_next;
            end if;
        end if;
    end process;

    Instruction <= mem(conv_integer(PC(6 downto 2)));
    PCPlus <= PC_plus;

end Behavioral;
