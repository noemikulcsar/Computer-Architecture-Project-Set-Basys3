--17. Sa se calculeze produsul a 2 numere pozitive X (X? 255) si Y (Y?255) citite din
--memorie de la adresele 0, respectiv 4. Rezultatul se va scrie in memorie la adresa
--8. Calculul va avea la baza adun?ri repetate, astfel: se parcurg bitii lui Y de la Y0
--la Y7 si daca bitul curent este 1 se aduna la rezultatul final valoarea lui X, deplasata
--la stanga cu numarul corespunzator de pozitii.
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
b"100011_00000_00010_0000000000000000",--X"8C02_0000"--00-- lw $2, 0($0)
b"100011_00000_00011_0000000000000100",--X"8C03_0004"--01-- lw $3, 4($0)
b"000000_00000_00000_00100_00000_100000",--X"0000_2020"--02--add $4,$0,$0 # rezultatul inmultirii
b"001000_00000_00101_0000000000001000",--X"2005_0008"--03--addi $5,$0,8 #numarul de iteratii
b"001000_00000_00110_0000000000000000",--X"2006_0000"--04--addi $6,$0,0 #i=0...7
b"000000_00000_00011_00111_00000_100000",--X"0003_3820"--05--add $7,$0,$3 #auxiliar Y(shiftam la dreapta pentru a parcurge toti bitii)
b"000000_00000_00010_01001_00000_100000",--X"0002_4820"--06--add $9,$0,$2 #auxiliar X(shiftam la stanga)
b"000100_00101_00110_0000000000000111",--X"10A6_0007"--07--beq $5,$6,7 #bucla pentru parcurgere
b"001100_00111_01000_0000000000000001",--X"30E8_0000"--08--andi $8,$7,1 pentru a determina daca adunam sau nu X
b"000100_01000_00000_0000000000000001",--X"1100_0001"--09--beq $8,$0,1
b"000000_00100_01001_00100_00000_100000",--X"0089_2020"--10--add $4,$4,$9 #actualizam inmultirea
b"000000_00000_01001_01001_00001_000000",--X"0009_4840"--11--sll $9,$9,1
b"000000_00000_00111_00111_00001_000010",--X"0007_3842"--12--srl $7,$7,1
b"001000_00110_00110_0000000000000001",--X"20C_60001"--13--addi $6,$6,1
b"000010_00000000000000000000000111",--X"0800_0007"--14--j 7
b"101011_00000_00100_0000000000001000",--X"AC04_0000"--15--sw $4,8($0)
b"100011_00000_01010_0000000000001000",--X"8C0A_0008"--lw $10,8($0) #sa verificam ca s-a stocat corect in memorie
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
