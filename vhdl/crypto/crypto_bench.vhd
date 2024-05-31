library ieee;
use ieee.std_logic_1164.all;

use work.crypto_pkg.all;

entity crypto_bench is
    generic(
        plaintext: w128 := x"0123456789ABCDEFFEDCBA9876543210";
        key: w128 := x"0123456789ABCDEFFEDCBA9876543210";
        ciphertext: w128 := x"681EDF34D206965E86B3E94F536E4246"
    );
end entity crypto_bench;

architecture bench of crypto_bench is

    signal clk: std_ulogic;
    signal sresetn: std_ulogic;
    signal shift: std_ulogic;
    signal go: std_ulogic;
    signal dec: std_ulogic;
    signal din: w128;
    signal done: std_ulogic;
    signal dout: std_ulogic_vector(255 downto 0);

begin


    clock0: process
    begin
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
    end process;

    crypto_test0: entity work.crypto_tests(rtl)
        port map(
            clk => clk,
            sresetn => sresetn,
            shift => shift,
            go => go,
            dec => dec,
            din => din,
            done => done,
            dout => dout
        );

    bench0: process
    begin
        -- Reset crypto engine
        sresetn <= '0';
        go <= '0';
        dec <= '0';
        shift <= '0';
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;

        sresetn <= '1';
        wait until rising_edge(clk);

        -- Loading register for encryption:
        shift <= '1';
        din <= key;
        wait until rising_edge(clk);
        din <= plaintext;
        wait until rising_edge(clk);
        shift <= '0';
        wait until rising_edge(clk);

        -- Encrytion test:
        go <= '1';
        wait until done = '1' and rising_edge(clk);
        shift <= '1';
        wait until rising_edge(clk);
        shift <= '0';
        wait until rising_edge(clk);
        assert dout(127 downto 0) = ciphertext report "Encryption went wrong: ciphertext not matching expected one" severity failure;
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        
        -- Reset crypto engine
        sresetn <= '0';
        go <= '0';
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;

        sresetn <= '1';
        wait until rising_edge(clk);

        -- Loading register for decryption:
        dec <= '1';
        shift <= '1';
        din <= key;
        wait until rising_edge(clk);
        din <= ciphertext;
        wait until rising_edge(clk);
        shift <= '0';
        wait until rising_edge(clk);

        -- Encrytion test:
        go <= '1';
        wait until done = '1' and rising_edge(clk);
        shift <= '1';
        wait until rising_edge(clk);
        shift <= '0';
        wait until rising_edge(clk);
        assert dout(127 downto 0) = plaintext report "Decryption went wrong: ciphertext not matching expected one" severity failure;
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;

    end process;

end architecture bench;
