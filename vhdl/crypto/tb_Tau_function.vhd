library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.crypto_pkg.all;

entity tb_Tau_function is
end entity tb_Tau_function;

architecture behavior of tb_Tau_function is

    -- Test signals
    signal tau_in : zi;
    signal tau_out : zi;

begin

    -- Instantiate the Unit Under Test (UUT)
    process
    begin
        -- Test vector 1
        tau_in <= x"01234567";
        wait for 10 ns;
        tau_out <= Tau(tau_in);
        wait for 10 ns;
        assert tau_out = x"90F473A2" report "Mismatch for input x'01234567'" severity failure;
        report "Test Vector 1: tau_out = " & to_hstring(tau_out);

        -- Test vector 2
        tau_in <= x"89abcdef";
        wait for 10 ns;
        tau_out <= Tau(tau_in);
        wait for 10 ns;
        assert tau_out = x"F7AB1084" report "Mismatch for input x'89abcdef'" severity failure;
        report "Test Vector 2: tau_out = " & to_hstring(tau_out);

        -- Test vector 3
        tau_in <= x"fedcba98";
        wait for 10 ns;
        tau_out <= Tau(tau_in);
        wait for 10 ns;
        report "Test Vector 3: tau_out = " & to_hstring(tau_out);

        -- Test vector 4
        tau_in <= x"76543210";
        wait for 10 ns;
        tau_out <= Tau(tau_in);
        wait for 10 ns;
        report "Test Vector 4: tau_out = " & to_hstring(tau_out);

        -- Add more test vectors as needed...

        report "All tests passed!";
        wait;
    end process;

end architecture behavior;
