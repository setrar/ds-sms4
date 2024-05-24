library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.crypto_pkg.all;

entity tb_Sbox_function is
end entity tb_Sbox_function;

architecture behavior of tb_Sbox_function is

    -- Test signals
    signal sbox_in : zijie;
    signal sbox_out : zijie;

begin

    -- Instantiate the Unit Under Test (UUT)
    process
    begin
        -- Test vector 0
        sbox_in <= x"ef"; -- Expected output: 84
        wait for 10 ns;
        sbox_out <= Sbox(sbox_in);
        wait for 10 ns;
        assert sbox_out = x"84" report "Mismatch for input x'ef'" severity failure;

        -- Test vector 1
        sbox_in <= x"00"; -- Expected output: D6
        wait for 10 ns;
        sbox_out <= Sbox(sbox_in);
        wait for 10 ns;
        assert sbox_out = x"D6" report "Mismatch for input x'00'" severity failure;

        -- Test vector 2
        sbox_in <= x"0F"; -- Expected output: 05
        wait for 10 ns;
        sbox_out <= Sbox(sbox_in);
        wait for 10 ns;
        assert sbox_out = x"05" report "Mismatch for input x'0F'" severity failure;

        -- Test vector 3
        sbox_in <= x"1A"; -- Expected output: 13
        wait for 10 ns;
        sbox_out <= Sbox(sbox_in);
        wait for 10 ns;
        assert sbox_out = x"13" report "Mismatch for input x'1A'" severity failure;

        -- Test vector 4
        sbox_in <= x"3C"; -- Expected output: 75
        wait for 10 ns;
        sbox_out <= Sbox(sbox_in);
        wait for 10 ns;
        assert sbox_out = x"75" report "Mismatch for input x'3C'" severity failure;

        -- Test vector 5
        sbox_in <= x"5A"; -- Expected output: 01
        wait for 10 ns;
        sbox_out <= Sbox(sbox_in);
        wait for 10 ns;
        assert sbox_out = x"0f" report "Mismatch for input x'5A'" severity failure;

        -- Add more test vectors as needed...

        report "All tests passed!";
        wait;
    end process;

end architecture behavior;
