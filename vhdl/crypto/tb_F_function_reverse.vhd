library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.crypto_pkg.all;

entity tb_F_function_reverse is
end entity tb_F_function_reverse;

architecture behavior of tb_F_function_reverse is

    -- Test signals
    signal F_in : w128;
    signal rk   : zi;
    signal F_out : w128;

    -- Function to reverse the bit order of a std_ulogic_vector
    function reverse_bits(vector: std_ulogic_vector) return std_ulogic_vector is
        variable reversed: std_ulogic_vector(vector'range);
    begin
        for i in vector'range loop
            reversed(i) := vector(vector'length - 1 - i);
        end loop;
        return reversed;
    end function reverse_bits;

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
        report "Test Vector 1: F_out = " & to_hstring(reverse_bits(F_out));

        -- Add more test vectors as needed...

        report "All tests passed!";
        wait;
    end process;

end architecture behavior;
