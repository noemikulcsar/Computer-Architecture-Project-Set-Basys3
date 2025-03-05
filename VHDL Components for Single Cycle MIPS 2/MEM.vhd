library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity MEM is
  Port (
  MemWrite : in std_logic;
  ALUResin : std_logic_vector(31 downto 0);
  RD2 : in std_logic_vector(31 downto 0);
  clk : in std_logic;
  en : in std_logic;
  MemData : out std_logic_vector(31 downto 0);
  ALUResout : out std_logic_vector(31 downto 0)
   );
end MEM;

architecture Behavioral of MEM is
type data_memory is array(0 to 63) of std_logic_vector(31 downto 0);
signal MEM : data_memory :=(
    X"00000014",--00--A(=20 in sistemul zecimal)
    X"00000000",--04--suma
    X"F0000000",--08
    X"00000000",--12 
    X"00000000",--16 
    X"10000001",--20--de aici incepe sirul
    X"20000002",--24
    X"30000003",--28
    X"40000004",--32
    X"50000005",--36
    X"60000006",--40
    X"70000007",--44
    X"80000008",--48(suma va fi egala la final cu 36, adica 24 in hexa)
    others => X"0000000"
);
begin
process(clk)
begin
    if rising_edge(clk) then
        if en = '1' and MemWrite = '1' then
            MEM(conv_integer(ALUResin(7 downto 2)))<=RD2;
        end if;
    end if;
end process;
MemData <= MEM(conv_integer(ALUResin(7 downto 2)));
ALUResout <= ALUResin;
end Behavioral;
