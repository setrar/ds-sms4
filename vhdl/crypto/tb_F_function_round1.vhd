library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.crypto_pkg.all;

entity tb_F_function_round1 is
end entity tb_F_function_round1;

architecture behavior of tb_F_function_round1 is

    -- Test signals
    signal F_in : w128;
    signal rk   : zi;
    signal F_out : w128;

begin

    -- Instantiate the Unit Under Test (UUT)
    process
    begin
        -- Test vector 1
        F_in <= x"0123456789abcdeffedcba9876543210";
        rk <= x"f12186f9";
        wait for 10 ns;
        F_out <= F(F_in, rk);
        wait for 10 ns;

        -- Display result
        report "Test Vector 1: F_in = " & to_hstring(F_in);
        report "Test Vector 1: F_out = " & to_hstring(F_out);

        -- Test vector 2
        F_in <= x"0123456789abcdeffedcba9876543210";
        rk <= x"41662b61";
        wait for 10 ns;
        F_out <= F(F_in, rk);
        wait for 10 ns;

        -- Display result
        report "Test Vector 2: F_in = " & to_hstring(F_in);
        report "Test Vector 2: F_out = " & to_hstring(F_out);

        -- Add more test vectors as needed...

        wait;
    end process;

end architecture behavior;
