--4. Sa se scrie primele N elemente ale sirului lui Fibonacci, inmultite cu 8, la locatii
--consecutive in memorie, pe 32 de biti, incepand cu adresa A (A?8). Valorile A si N
--se citesc din memorie de la adresele 0, respectiv 4. Pentru verificare, se poate
--adauga o bucla de citire a elementelor sirului, la final.
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
b"100011_00000_00001_0000000000000000",--X"8C01_0000"--00--lw $1,0($0) #A va fi indexul de memorie
b"100011_00000_00010_0000000000000100",--X"8C02_0004"--01--lw $2,4($0) #incarcam valoarea lui N din memorie
b"001000_00000_00011_0000000000000001",--X"2003_0001"--02--addi $3,$0,1 
b"001000_00000_00100_0000000000000001",--X"2004_0001"--03--addi $4,$0,1
b"001000_00000_00101_0000000000000010",--X"2005_0002"--04--addi $5,$0,2 #aici vom stoca urmatorul numar fibonacci
b"001000_00000_00110_0000000000000000",--X"2006_0000"--05--addi $6,$0,0 #contorul buclei, la inceput 0
b"000100_00010_00110_0000000000001001",--X"1046_0009"--06--beq $2,$6,9
b"000000_00000_00011_00111_00000_100000",--X"0003_3820"--07--add $7,$0,$3
b"000000_00000_00111_00111_00011_000000",--X"0007_38C0"--08--sll $7,$7,3 #inmultim cu 8 elementul ce va fi stocat in memorie
b"101011_00001_00111_0000000000000000",--X"AC27_0000"--09--sw $7,0($1) #stocam elementul din sirul lui fibonacci
b"000000_00000_00100_00011_00000_100000",--X"0004_1820"--10--add $3,$0,$4
b"000000_00000_00101_00100_00000_100000",--X"0005_2020"--11--add $4,$0,$5
b"000000_00011_00100_00101_00000_100000",--X"0064_2820"--12--add $5,$3,$4
b"001000_00110_00110_0000000000000001",--X"20C6_0001"--13--addi $6,$6,1 #contor++
b"001000_00001_00001_0000000000000100",--X"2021_0004"--14--addi $1,$1,4 #index de memorie +=4
b"000010_00000000000000000000000110",--X"0800_0006"--15--j 6
b"100011_00000_00001_0000000000000000",--X"8C01_0000"--16--lw $1,0($0) #A pentru a verifica bucla
b"001000_00000_00110_0000000000000000",--X"2006_0000"--17--addi $6,$0,0
b"000100_00010_00110_0000000000000100",--X"1046_0004"--18--beq $6,$2,4
b"100011_00001_01000_0000000000000000",--X"8C28_0000"--19--lw $8,0($1)
b"001000_00110_00110_0000000000000001",--X"20C6_0001"--20--addi $6,$6,1 #contor++
b"001000_00001_00001_0000000000000100",--X"2021_0004"--21--addi $1,$1,4 #index de memorie +=4
b"000010_00000000000000000000010010",--X"0800_0012"--22--j 18
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
