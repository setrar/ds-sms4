-- File: cipher_pkg-body.vhd
package body cipher_pkg is
    function rotate_left(i32 : unsigned; k : integer) return unsigned is
    begin
        return (i32 sll k) or (i32 srl (32 - k));
    end function;

    function tau(i32 : unsigned) return unsigned is
        variable result : unsigned(31 downto 0);
    begin
        result(31 downto 24) := unsigned(S(to_integer(unsigned(i32(31 downto 24)))));
        result(23 downto 16) := unsigned(S(to_integer(unsigned(i32(23 downto 16)))));
        result(15 downto 8) := unsigned(S(to_integer(unsigned(i32(15 downto 8)))));
        result(7 downto 0) := unsigned(S(to_integer(unsigned(i32(7 downto 0)))));
        return result;
    end function;

    function linear_substitution_0(i32 : unsigned) return unsigned is
    begin
        return i32 xor rotate_left(i32, 2) xor rotate_left(i32, 10) xor rotate_left(i32, 18) xor rotate_left(i32, 24);
    end function;

    function linear_substitution_1(i32 : unsigned) return unsigned is
    begin
        return i32 xor rotate_left(i32, 13) xor rotate_left(i32, 23);
    end function;
end package body;
