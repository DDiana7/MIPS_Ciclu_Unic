----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2025 06:45:31 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Adapted test environment for instruction fetch and decode
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
-- use IEEE.NUMERIC_STD.ALL; -- Optional, not used in current design

entity test_env is
    Port (
        clk : in STD_LOGIC;
        btn : in STD_LOGIC_VECTOR(4 downto 0);
        sw : in STD_LOGIC_VECTOR(15 downto 0);
        led : out STD_LOGIC_VECTOR(15 downto 0);
        an : out STD_LOGIC_VECTOR(7 downto 0);
        cat : out STD_LOGIC_VECTOR(6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

    component MPG is
        Port (
            enable : out STD_LOGIC;
            btn : in STD_LOGIC;
            clk : in STD_LOGIC
        );
    end component;

    component SSD is
        Port (
            clk : in STD_LOGIC;
            digits : in STD_LOGIC_VECTOR(31 downto 0);
            an : out STD_LOGIC_VECTOR(7 downto 0);
            cat : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component IFetch is
        Port (
            Jump : in STD_LOGIC;
            JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
            PCSrc : in STD_LOGIC;
            BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
            Enable : in STD_LOGIC;
            Reset : in STD_LOGIC;
            clk : in STD_LOGIC;
            PCPlus : out STD_LOGIC_VECTOR(31 downto 0);
            Instruction : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component UC is
        Port ( 
            Instr : in STD_LOGIC_VECTOR (5 downto 0);
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
    end component;

    component ID is
        Port (
            clk : in STD_LOGIC;
            RegWrite : in STD_LOGIC;
            Instr : in STD_LOGIC_VECTOR(25 downto 0);
            RegDst : in STD_LOGIC;
            EN : in STD_LOGIC;
            ExtOp : in STD_LOGIC;
            WD : in STD_LOGIC_VECTOR(31 downto 0);
            RD1 : out STD_LOGIC_VECTOR(31 downto 0);
            RD2 : out STD_LOGIC_VECTOR(31 downto 0);
            Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
            func : out STD_LOGIC_VECTOR(5 downto 0);
            sa : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

 component EX is
        Port ( 
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
    end component;

    component MEM is
        Port (
        clk           : in std_logic;
        mw            : in std_logic;  
        en            : in std_logic;
        ALUResultIn   : in std_logic_vector(31 downto 0);
        RD2           : in std_logic_vector(31 downto 0);
        MemData       : out std_logic_vector(31 downto 0);
        ALUResultOut  : out std_logic_vector(31 downto 0));
    end component;

    signal do : STD_LOGIC_VECTOR(31 downto 0);
    signal enable : STD_LOGIC;
    signal pcp : STD_LOGIC_VECTOR(31 downto 0);
    signal instr : STD_LOGIC_VECTOR(31 downto 0);

    signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);
    signal RegDst : STD_LOGIC;
    signal ExtOp : STD_LOGIC;
    signal ALUSrc : STD_LOGIC;
    signal Branch : STD_LOGIC;
    signal Br_GTZ : STD_LOGIC;
    signal Jmp : STD_LOGIC;
    signal MemWrite : STD_LOGIC;
    signal MemtoReg : STD_LOGIC;
    signal RegWrite : STD_LOGIC;
    
    signal RD1, RD2, WD : STD_LOGIC_VECTOR(31 downto 0);
    signal Ext_Imm : STD_LOGIC_VECTOR(31 downto 0);
    signal func : STD_LOGIC_VECTOR(5 downto 0);
    signal sa : STD_LOGIC_VECTOR(4 downto 0);
    
    signal ALURes : std_logic_vector(31 downto 0);
    signal ALUResOut : std_logic_vector(31 downto 0);
    signal zero, gtz : std_logic;
    signal BranchAddress : std_logic_vector(31 downto 0);
    signal memData : std_logic_vector(31 downto 0);
    
    signal BranchAddrCalc : std_logic_vector(31 downto 0);
    signal PCSrc : std_logic;
    signal jumpAddr : std_logic_vector(31 downto 0);

begin

    MPG_inst : MPG
        port map (
            enable => enable,
            btn => btn(0),
            clk => clk
        );

    SSD_inst : SSD
        port map (
            clk => clk,
            digits => do,
            an => an,
            cat => cat
        );

    IFetch_inst : IFetch
        port map (
            Jump => Jmp,
            JumpAddress => jumpAddr,
            PCSrc => PCSrc,
            BranchAddress => BranchAddrCalc,
            Enable => enable,
            Reset => btn(1),
            clk => clk,
            PCPlus => pcp,
            Instruction => instr
        );

    UC_inst : UC
        port map (
            Instr => instr(31 downto 26),
            RegDst => RegDst,
            ExtOp => ExtOp,
            ALUSrc => ALUSrc,
            Branch => Branch,
            ALUOp => ALUOp,
            MemWrite => MemWrite,
            MemtoReg => MemtoReg,
            RegWrite => RegWrite,
            Jump => Jmp,
            Br_GTZ => Br_GTZ
        );

    ID_inst : ID
        port map (
            clk => clk,
            RegWrite => RegWrite,
            Instr => instr(25 downto 0),
            RegDst => RegDst,
            EN => enable,
            ExtOp => ExtOp,
            WD => WD,
            RD1 => RD1,
            RD2 => RD2,
            Ext_Imm => Ext_Imm,
            func => func,
            sa => sa
        );
    
    EX_inst : EX
        port map (
            rd1 => RD1,
            ALUSrc => ALUSrc,
            rd2 => RD2,
            Ext_imm => Ext_Imm,
            sa => sa,
            func => func,
            ALUOp => ALUOp,
            pcp => pcp,
            gtz => gtz,
            zero => zero,
            ALURes => ALURes,
            badd => BranchAddrCalc
        );
        
    MEM_inst : MEM
        port map (
            clk => clk,
            en => enable,
            mw => MemWrite, 
            ALUResultIn =>ALURes,
            RD2 =>RD2,
            MemData => memData,
            ALUResultOut => ALUResOut
        );
        
    WD <= memData when MemtoReg = '1' else ALUResOut;    
    
    PCSrc <= (Branch and zero) when Br_GTZ = '0' else(Br_GTZ and gtz);
    
    jumpAddr <= pcp(31 downto 28) & instr(25 downto 0) & "00";

    
    do <= instr     when sw(7 downto 5) = "000" else
          pcp       when sw(7 downto 5) = "001" else
          RD1       when sw(7 downto 5) = "010" else
          RD2       when sw(7 downto 5) = "011" else
          WD        when sw(7 downto 5) = "100" else
          Ext_Imm   when sw(7 downto 5) = "101" else
          ALURes    when sw(7 downto 5) = "110" else
          memData   when sw(7 downto 5) = "111" else
          (others => '0');


    
   led(15 downto 9) <= (others => '0');  
    led(8)  <= RegDst;
    led(7)  <= ExtOp;
    led(6)  <= ALUSrc;
    led(5)  <= Branch;
    led(4)  <= Jmp;
    led(3)  <= MemWrite;
    led(2)  <= MemtoReg;
    led(1)  <= RegWrite;
    led(0)  <= Br_GTZ;      

end Behavioral;
