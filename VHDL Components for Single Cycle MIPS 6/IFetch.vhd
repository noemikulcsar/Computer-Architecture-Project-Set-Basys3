--13. Sa se parcurga memoria de la adresa A (A?12) pana se intalneste o valoare
--nula si sa se determine cate valori intalnite sunt mai mici ca X. X ?i A se citesc din
--memorie de la adresele 0, respectiv 4, iar rezultatul se va scrie la adresa 8.
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
b"100011_00000_00001_0000000000000000",--X"8C01_0000"--00--lw $1,0($0) #citim X
b"100011_00000_00010_0000000000000100",--X"8C020008"--01--lw $2,4($0) #citim A
b"100011_00010_00011_0000000000000000",--X"8C430000"--02--lw $3,0($2) #primul element din vector
b"000000_00000_00000_00100_00000_100000",--X"0000_2020"--03--add $4,$0,$0 #contorul rezultat
b"000100_00011_00000_0000000000000110",--X"10600006"--04--beq $3,$0, 6 #daca elementul curent e zero, sarim la stocarea rezultatului
b"000000_00011_00001_00101_00000_100010",--X"0061_2822"--05--sub $5,$3,$1 #facem diferenta dintre elementul curent si X
b"000001_00101_00000_0000000000000001",--X"04A00001"--06--bgez $5,1 #daca elementul curent - X > 0 sarim
b"001000_00100_00100_0000000000000001",--X"20840001"--07--addi $4,$4,1 #rezultat++
b"001000_00010_00010_0000000000000100",--X"20420004"--08--addi $2,$2,4
b"100011_00010_00011_0000000000000000",--X"8C430000"--09--lw $3,0($2)
b"000010_00000000000000000000000100",--X"08000004"--10--j 4
b"101011_00000_00100_0000000000001000",--X"AC060008"--11--sw $4,8($0)
b"100011_00000_00110_0000000000001000",--X"8C06_0008"--12--lw $6,8($0) #sa vedem daca e stocata valoarea corecta in memorie
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
