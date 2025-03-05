--5. Sa se inlocuiasca fiecare element xi, dintr-un sir de dimensiune N, cu valoarea
--xi + xi+1, unde i=1,N-1 ?i xN cu xN + x1. Sirul se afla in memorie incepand cu
--adresa 4. N se citeste de la adresa 0. Pentru verificare, se poate adauga o bucla
--de citire a elementelor sirului, la final.
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
--ne trebuie copie a primului element
b"100011_00000_00001_0000000000000000",--X"8C01_0000"--00--lw $1,0($0) #citim N
b"001000_00010_00010_0000000000000000",--X"2042_0000"--01--addi $2,$2,0 #iteratorul buclei i=0
b"001000_00001_00011_1111111111111111",--X"2023_FFFF"--02--addi $3,$1,-1 #numarul maxim de iteratii
b"001000_00000_00100_0000000000000100",--X"2004_0004"--03--addi $4,$0,4 #indexul de memorie
b"100011_00100_00101_0000000000000000",--X"8C85_0000"--04--lw $5,0($4) #copie a primului element ce va fi necesara la finalul buclei
b"000100_00010_00011_0000000000001000",--X"1043_0008"--05--beq $2,$3,8
b"100011_00100_00110_0000000000000000",--X"8C86_0000"--06--lw $6,0($4) #x(i)
b"001000_00100_00111_0000000000000100",--X"2087_0004"--07--addi $7,$4,4 #index+4 pentru a obtine indexul urmatorului element
b"100011_00111_01000_0000000000000000",--X"8C88_0000"--08--lw $8,0($7) #x(i+1)
b"000000_00110_01000_01001_00000_100000",--X"00C8_4820"--09--add $9,$6,$8 
b"101011_00100_01001_0000000000000000",--X"ACE9_0000"--10--sw $9,0($4) #stocam noul element x(i)=x(i)+x(i+1)
b"001000_00100_00100_0000000000000100",--X"2084_0004"--11--addi $4,$4,4 #index+=4
b"001000_00010_00010_0000000000000001",--X"2042_0001"--12--addi $2,$2,1 #i++
b"000010_00000000000000000000000101",--X"800_0005"--13--j 5 #repetam pana la penultimul element
b"000000_01000_00101_01001_00000_100000",--X"0105_4820"--14--add $9,$8,$5
b"101011_00100_01001_0000000000000000",--X"AC89_0000"--15--sw $9,0($4) #x(N)=x(1)+x(N)
b"001000_00000_00010_0000000000000000",--X"2002_0000"--16--addi $2,$0,0 #reinitializam iteratorul
b"001000_00000_00100_0000000000000100",--X"2004_0004"--17--addi $4,$0,4 #reinitializam indexul de memorie
b"000100_00010_00001_0000000000000100",--X"1041_0003"--18--beq $2,$1,4 for i=[0,N), de data asta parcurgem intreg vectorul, nu doar pana la N-1
b"100011_00100_00110_0000000000000000",--X"8C86_0000"--19--lw $6,0($4) #incarcam elementul din memorie
b"001000_00010_00010_0000000000000001",--X"2042_0001"--20--addi $2,$2,1 #incrementam iteratorul buclei
b"001000_00100_00100_0000000000000100",--X"2084_0004"--21--addi $4,$4,4 #incrementam indexul de memorie
b"000010_00000000000000000000010010",--X"0800_0012"--22--j 18 #bucla se repeta pana la finalul vectorului
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
