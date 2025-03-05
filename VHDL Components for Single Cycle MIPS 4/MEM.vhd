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
    X"00000008",--00--A(adresa de inceput)
    X"00000007",--04--N(numarul de elemente)
    X"00000000",--08--de aici vor fi scrise in memorie numerele lui Fibonacci
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
