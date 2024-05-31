library ieee;
use ieee.std_logic_1164.all;

use work.crypto_pkg.all;

entity crypto_tests is
    port (
        clk: in std_ulogic; -- Clock signal input
        sresetn: in std_ulogic; -- Reset signal input
        shift: in std_ulogic;
        go: in std_ulogic; -- Start signal input
        dec: in std_ulogic; -- Input signal to use the engine in ecryption or decryption mode
        din: in w128; -- 128 bit encryption key input
        done: out std_ulogic;
        dout: out std_ulogic_vector(255 downto 0)
    );
end entity crypto_tests;

architecture rtl of crypto_tests is
    signal key: w128;
    signal p: w128;
    signal c: w128;
    signal reg_in: w128;
begin
    sr0: process (clk) is -- Shift register for key, plaintext and ciphertext storage
    begin
        if (rising_edge(clk)) then -- synchronous on clock rising edge
            if (sresetn = '0') then
                dout <= (others => '0');
            elsif (shift = '1') then
                dout <= dout(127 downto 0) & reg_in;
            end if;
        end if;
    end process;

    crypto0: entity work.crypto_engine(rtl)
        port map(
            clk => clk,
            sresetn => sresetn,
            go => go,
            dec => dec,
            key => key,
            p => p,
            done => done,
            c => c
        );

    key <= dout(255 downto 128);
    p <= dout(127 downto 0);
    reg_in <= c when done = '1' else din;




end architecture rtl;