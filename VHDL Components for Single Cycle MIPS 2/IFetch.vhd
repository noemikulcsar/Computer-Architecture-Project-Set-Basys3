--2. Sa se parcurga un sir de 8 elemente aflat in memorie incepand cu adresa A
--(A?8) si pentru fiecare pozitie se va retine valoarea corespunzatoare primilor 16
--biti mai putin semnificativi, cu scopul de a calcula suma acestora. Valoarea A se
--citeste din memorie de la adresa 0. Suma se va scrie la adresa 4.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
Port(
 Jump: in std_logic;
 JumpAddress: in std_logic_vector(31 downto 0);
 PcSrc: in std_logic;
 BranchAddress: in std_logic_vector(31 downto 0);
 en: in std_logic;
 rst: in std_logic;
 clk: in std_logic;
 Instruction: out std_logic_vector(31 downto 0);
 NextAddress: out std_logic_vector(31 downto 0)
 );
end IFetch;

architecture Behavioral of IFetch is
type memorie_rom is array (0 to 31) of std_logic_vector(31 downto 0);
signal rom : memorie_rom :=(
b"001000_00000_00001_0000000000000000",--X"2001_0000"--00  addi $1,$0,0 #i=0, contorul buclei
b"100011_00000_00010_0000000000000000",--X"8C02_0000"--01 lw $2,0($0) #incarcam valoarea lui A din memorie
b"000000_00000_00010_00011_00000_100000",--X"0002_1820"--02 add $3,$0,$2 #initializam indexul de memorie
b"001000_00000_00100_0000000000001000",--X"2004_0008"--03 addi $4,$0,8 #numarul de iteratii ale buclei
b"001000_00101_00101_0000000000000000",--X"20A5_0000"--04 addi $5,$5,0 #aici vom calcula suma
b"000100_00001_00100_0000000000000111",--X"1024_0007"--05 beq $1,$4,7
b"100011_00011_00110_0000000000000000",--X"8C66_0000"--06 lw $6,0($3) #elementul curent din vector
b"000000_00000_00110_00110_10000_000000",--X"0006_3400"--07 sll $6,$6,16
b"000000_00000_00110_00110_10000_000010",--X"0006_3402"--08 srl $6,$6,16 #prin aceste shiftari ne asiguram ca primii 16 biti mai semnificativi au devenit 0
b"000000_00101_00110_00101_00000_100000",--X"00A6_2820"--09 add $5,$5,$6
b"001000_00011_00011_0000000000000100",--X"2063_0004"--10 addi $3,$3,4 #indexul de memorie +=4
b"001000_00001_00001_0000000000000001",--X"2021_0001"--11 addi $1,$1,1 #i++
b"000010_00000000000000000000000101",--X"0800_0005"--12 j 5
b"101011_00000_00101_0000000000000100",--X"AC05_0004"--13 sw $5,4($0) #stocam suma in memorie
b"100011_00000_00111_0000000000000100",--X"8C07_0004"--14 lw $7,4($0) #verificam daca s a stocat corect in memorie
others => X"00000000");

signal mux1:std_logic_vector(31 downto 0):=(others=>'0');
signal mux2:std_logic_vector(31 downto 0):=(others=>'0');
signal sum:std_logic_vector(31 downto 0):=(others=>'0');
signal q:std_logic_vector(31 downto 0):=(others=>'0');
begin

with Jump select mux1<=JumpAddress when '1',
                       mux2 when others;

with PcSrc select mux2<=BranchAddress when '1',
                       sum when others;
process(clk)
begin
if rst ='1' then
    q<=x"00000000";
    elsif rising_edge(clk) then 
        if en='1' then 
            q<=mux1;
        end if;
end if;
end process;
sum<=q+4;        
NextAddress<=sum;
Instruction <= rom(conv_integer(q(6 downto 2)));
end Behavioral;
