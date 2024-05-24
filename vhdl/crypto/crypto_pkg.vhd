--
-- Crypto PKG
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

package crypto_pkg is

    /*
    generic(type T);

    type foo_t is record
        a: std_logic_vector(5 downto 0);
        b: natural range 0 to 17;
    end record;
    type w128_array is array (natural range <>);
    */

    subtype w128 is std_ulogic_vector(127 downto 0);
    subtype zi is std_ulogic_vector(31 downto 0);
    subtype zijie is std_ulogic_vector(7 downto 0);

    type type_sbox is array (0 to 15, 0 to 15) of std_ulogic_vector(7 downto 0); --sbox substitution table

    constant sbox_constant : type_sbox := 
    (
        (x"D6", x"90", x"E9", x"FE", x"CC", x"E1", x"3D", x"B7", x"16", x"B6", x"14", x"C2", x"28", x"FB", x"2C", x"05"),
        (x"2B", x"67", x"9A", x"76", x"2A", x"BE", x"04", x"C3", x"AA", x"44", x"13", x"26", x"49", x"86", x"06", x"99"),
        (x"9C", x"42", x"50", x"F4", x"91", x"EF", x"98", x"7A", x"33", x"54", x"0B", x"43", x"ED", x"CF", x"AC", x"62"),
        (x"E4", x"B3", x"1C", x"A9", x"C9", x"08", x"E8", x"95", x"80", x"DF", x"94", x"FA", x"75", x"8F", x"3F", x"A6"),
        (x"47", x"07", x"A7", x"FC", x"F3", x"73", x"17", x"BA", x"83", x"59", x"3C", x"19", x"E6", x"85", x"4F", x"A8"),
        (x"68", x"6B", x"81", x"B2", x"71", x"64", x"DA", x"8B", x"F8", x"EB", x"0F", x"4B", x"70", x"56", x"9D", x"35"),
        (x"1E", x"24", x"0E", x"5E", x"63", x"58", x"D1", x"A2", x"25", x"22", x"7C", x"3B", x"01", x"21", x"78", x"87"),
        (x"D4", x"00", x"46", x"57", x"9F", x"D3", x"27", x"52", x"4C", x"36", x"02", x"E7", x"A0", x"C4", x"C8", x"9E"),
        (x"EA", x"BF", x"8A", x"D2", x"40", x"C7", x"38", x"B5", x"A3", x"F7", x"F2", x"CE", x"F9", x"61", x"15", x"A1"),
        (x"E0", x"AE", x"5D", x"A4", x"9B", x"34", x"1A", x"55", x"AD", x"93", x"32", x"30", x"F5", x"8C", x"B1", x"E3"),
        (x"1D", x"F6", x"E2", x"2E", x"82", x"66", x"CA", x"60", x"C0", x"29", x"23", x"AB", x"0D", x"53", x"4E", x"6F"),
        (x"D5", x"DB", x"37", x"45", x"DE", x"FD", x"8E", x"2F", x"03", x"FF", x"6A", x"72", x"6D", x"6C", x"5B", x"51"),
        (x"8D", x"1B", x"AF", x"92", x"BB", x"DD", x"BC", x"7F", x"11", x"D9", x"5C", x"41", x"1F", x"10", x"5A", x"D8"),
        (x"0A", x"C1", x"31", x"88", x"A5", x"CD", x"7B", x"BD", x"2D", x"74", x"D0", x"12", x"B8", x"E5", x"B4", x"B0"),
        (x"89", x"69", x"97", x"4A", x"0C", x"96", x"77", x"7E", x"65", x"B9", x"F1", x"09", x"C5", x"6E", x"C6", x"84"),
        (x"18", x"F0", x"7D", x"EC", x"3A", x"DC", x"4D", x"20", x"79", x"EE", x"5F", x"3E", x"D7", x"CB", x"39", x"48")
    );

    type type_FK is array (0 to 3) of std_ulogic_vector(31 downto 0); --FK constants LUT

    constant FK : type_FK := (
        x"A3B1BAC6", x"56AA3350", x"677D9197", x"B27022DC"
    );

    type type_CK is array (0 to 31) of std_ulogic_vector(31 downto 0); --CK constants LUT

    constant CK : type_CK := (
        x"00070E15", x"1C232A31", x"383F464D", x"545B6269",
        x"70777E85", x"8C939AA1", x"A8AFB6BD", x"C4CBD2D9",
        x"E0E7EEF5", x"FC030A11", x"181F262D", x"343B4249",
        x"50575E65", x"6C737A81", x"888F969D", x"A4ABB2B9",
        x"C0C7CED5", x"DCE3EAF1", x"F8FF060D", x"141B2229",
        x"30373E45", x"4C535A61", x"686F767D", x"848B9299",
        x"A0A7AEB5", x"BCC3CAD1", x"D8DFE6ED", x"F4FB0209",
        x"10171E25", x"2C333A41", x"484F565D", x"646B7279"
    );

    function Sbox(sbox_in: zijie) return zijie;
    function Tau(A: zi) return zi;
    function L(B: zi) return zi;
    function LPrime(B: zi) return zi;
    function F(F_in: w128; rk: zi) return w128;
    function R(A: w128) return w128;
    function compute_initials_rks(MK: w128) return w128;
    function compute_next_rki(K: w128; i: integer range 0 to 31) return w128;


end package crypto_pkg;

package body crypto_pkg is

    function Sbox(sbox_in: zijie) return zijie is
    begin
        return sbox_constant(to_integer(unsigned(sbox_in(7 downto 4))), to_integer(unsigned(sbox_in(3 downto 0))));
    end function Sbox;

    function Tau(A: zi) return zi is
        variable B: zi;
    begin
        B := Sbox(A(31 downto 24)) & Sbox(A(23 downto 16)) & Sbox(A(15 downto 8)) & Sbox(A(7 downto 0));
        return B;
    end function Tau;

    function L(B: zi) return zi is
        variable C: zi;
    begin
        C := B xor (B rol 2) xor (B rol 10) xor (B rol 18) xor (B rol 24);
        return C;
    end function L;

    function LPrime(B: zi) return zi is
        variable C: zi;
    begin
        C := B xor (B rol 13) xor (B rol 23);
        return C;
    end function LPrime;

    function F(F_in: w128; rk: zi) return w128 is
        alias X3: zi is F_in(31 downto 0);
        alias X2: zi is F_in(63 downto 32);
        alias X1: zi is F_in(95 downto 64);
        alias X0: zi is F_in(127 downto 96);
        variable X4: zi;
    begin
        X4 := X0 xor L(Tau(X1 xor X2 xor X3 xor rk));
        return X1 & X2 & X3 & X4;
    end function F;

    function R(A: w128) return w128 is
        alias A0: zi is A(31 downto 0);
        alias A1: zi is A(63 downto 32);
        alias A2: zi is A(95 downto 64);
        alias A3: zi is A(127 downto 96);
    begin
        return A0 & A1 & A2 & A3;
    end function R;

    function compute_initials_rks(MK: w128) return w128 is
        alias MK0: zi is MK(31 downto 0);
        alias MK1: zi is MK(63 downto 32);
        alias MK2: zi is MK(95 downto 64);
        alias MK3: zi is MK(127 downto 96);
    begin
        return (MK3 xor FK(3)) & (MK2 xor FK(2)) & (MK1 xor FK(1)) & (MK0 xor FK(0));
    end function compute_initials_rks;

    function compute_next_rki(K: w128; i: integer range 0 to 31) return w128 is
        alias Ki0: zi is K(31 downto 0);
        alias Ki1: zi is K(63 downto 32);
        alias Ki2: zi is K(95 downto 64);
        alias Ki3: zi is K(127 downto 96);
        variable Ki4: zi;
    begin
        Ki4 := Ki0 xor LPrime(Tau(Ki1 xor Ki2 xor Ki3 xor CK(i)));
        return Ki4 & Ki3 & Ki2 & Ki1;
    end function compute_next_rki;

end package body crypto_pkg;
