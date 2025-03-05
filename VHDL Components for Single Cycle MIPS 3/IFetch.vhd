--3. S? se inlocuiasc? fiecare element xi, dintr-un sir de dimensiune N, cu valoarea
--xi - xN-i+1, unde i=1,N. Sirul se afla in memorie incepand cu adresa 4. N se citeste
--de la adresa 0. Pentru verificare, se poate adauga o bucla de citire a elementelor
--sirului, la final.
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
--modificam cate 2 elemente deodata
--tratare separata pentru caz par/impar la finalul buclei
b"100011_00000_00001_0000000000000000",--X"8C01_0000"--00--lw $1,0($0) #incarcam din memorie valoarea lui N
b"000000_00000_00000_00010_00000_100000",--X"0000_1020"--01--add $2,$0,$0 #contorul buclei i=0
b"001000_00000_00011_0000000000000001",--X"2003_0001"--02--addi $3,$0,1 #pentru a verifica daca N este par/impar
b"000000_00011_00001_00100_00000_100100",--X"0061_2024"-03--and $4,$3,$1 #e egal cu 1 daca e impar, 0 daca e par
b"000000_00000_00001_00101_00000_100000",--X"0001_2820"--04--add $5,$0,$1 #copie a valorii N
b"000000_00000_00101_00101_00001_000010",--X"0005_2842"--05--srl $5,$5,1 #impartim la 2 pentru a parcurge doar jumatate din vector
b"001000_00000_00110_0000000000000100",--X"2006_0004"--06--addi $6,$0,4 #indexul de memorie al vectorului pt x(i)
b"000000_00000_00001_00111_00010_000000",--X"0001_3880"--07--sll $7,$1,2 #inmultim cu 4 pt x(N), vom avea deci 2 indecsi de memorie
b"000100_00010_00101_0000000000001011",--X"1045_000B"--08--beq $2,$5,11
b"100011_00110_010000000000000000000",--X"8CC8_0000"--09--lw $8,0($6) #elementul x(i)
b"100011_00111_01001_0000000000000000",--X"8CE9_0000"--10--lw $9,0($7) #elementul x(N-i+1)
b"000000_01000_01001_01000_00000_100010",--X"0109_4022"--11--sub $8,$8,$9 #x(i)=x(i)-x(N-i+1)
b"000000_00000_01000_01001_00000_100010",--X"0008_4822"--12--sub $9,$0,$8 #x(N-i+1)=-noul x(i), pt ca x(i)-x(N-i+1)=-(x(N-i+1)-x(i))
b"101011_00110_01000_0000000000000000",--X"ACC8_0000"--13--sw $8,0($6) #stocam noul x(i)
b"101011_00111_01001_0000000000000000",--X"ACE9_0000"--14--sw $9,0($7) #stocam noul x(N-i+1)
b"001000_00110_00110_0000000000000100",--X"20C6_0004"--15--addi $6,$6,4
b"001000_00000_00011_0000000000000100",--X"2003_0004"--16--addi $3,$0,4
b"000000_00111_00011_00111_00000_100010",--X"00E3_3822"--17--sub $7,$7,$3
b"001000_00010_00010_0000000000000001",--X"2042_0001"--18--addi $2,$2,1
b"000010_00000000000000000000001000",--X"0800_0008"--19--j 8
b"000100_00000_00100_0000000000000001",--X"1004_0001"--20--beq $4,$0,1 #daca numarul e par nu avem caz special de tratat
b"101011_00110_00000_0000000000000000",--X"ACC0_0000"--21--sw $0,0($6) #elementul din mijloc va avea valoarea 0
b"000000_00000_00000_00010_00000_100000",--X"0000_1020"--22--add $2,$2,$0 #reinitializam contorul buclei
b"001000_00000_00110_0000000000000100",--X"2006_0004"--23--addi $6,$0,4 #reinitializam indexul de memorie
b"000100_00010_00001_0000000000000100",--X"1041_0004"--24--beq $2,$1,4
b"100011_00110_01000_0000000000000000",--X"8CC8_0000"--25--lw $8,0($6)
b"001000_00010_00010_0000000000000001",--X"2042_0001"--26--addi $2,$2,1 i++
b"001000_00110_00110_0000000000000100",--X"20C6_0004"--27--addi $6,$6,4 index+=4
b"000010_00000000000000000000011000",--X"0800_0018"--28--j 24
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
