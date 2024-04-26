--
-- Crypto PKG
--

package crypto_pkg is

    generic(type T);

    type foo_t is record
        a: std_logic_vector(5 downto 0);
        b: natural range 0 to 17;
    end record;
    subtype w128 is std_logic_vector(127 downto to);
    type w128_array is array (natural range <>);

end package crypto_pkg;

package body crypto_pkg is



end package body crypto_pkg;
