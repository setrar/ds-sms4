library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Cipher is
    -- Port definitions (if necessary)
end entity Cipher;

architecture Behavioral of Cipher is
    -- S-box array definition
    type S_box_type is array (0 to 255) of std_logic_vector(7 downto 0);
    constant S: S_box_type := (
        x"D6", x"90", x"E9", -- Only a partial list shown
        others => x"00"  -- Default for unspecified values
    );

    -- FK and CK constants
    type key_array is array (natural range <>) of unsigned(31 downto 0);
    constant FK: key_array := (x"A3B1BAC6", x"56AA3350", x"677D9197", x"B27022DC");
    constant CK: key_array := (
        x"00070E15", x"1C232A31", -- Only a partial list shown
        others => x"00000000"  -- Default for unspecified values
    );
end architecture;
