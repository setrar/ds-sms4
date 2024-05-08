-- File: cipher_pkg.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package cipher_pkg is
    -- Declare types and constants
    type S_box_type is array (0 to 255) of std_logic_vector(7 downto 0);
    constant S: S_box_type := (
        x"D6", x"90", x"E9", -- Only a partial list shown
        others => x"00"  -- Default for unspecified values
    );
    -- Declare functions
    function rotate_left(i32 : unsigned; k : integer) return unsigned;
    function tau(i32 : unsigned) return unsigned;
    function linear_substitution_0(i32 : unsigned) return unsigned;
    function linear_substitution_1(i32 : unsigned) return unsigned;
end package cipher_pkg;
