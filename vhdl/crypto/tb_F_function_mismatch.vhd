library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.crypto_pkg.all;

entity tb_F_function_mismatch is
end entity tb_F_function_mismatch;

architecture behavior of tb_F_function_mismatch is

    -- Test signals
    signal F_in : w128;
    signal rk   : zi;
    signal F_out : w128;
    
    -- Constants
    constant plaintext : w128 := x"0123456789ABCDEF0123456789ABCDEF";
    type rk_array_type is array (0 to 31) of zi;
    constant rk_array : rk_array_type := (
        x"f12186f9", x"41662b61", x"5a6ab19a", x"7ba92077", x"367360f4", x"776a0c61",
        x"b6bb89b3", x"24763151", x"a520307c", x"b7584dbd", x"c30753ed", x"7ee55b57",
        x"6988608c", x"30d895b7", x"44ba14af", x"104495a1", x"d120b428", x"73b55fa3",
        x"cc874966", x"92244439", x"e89e641f", x"98ca015a", x"c7159060", x"99e1fd2e",
        x"b79bd80c", x"1d2115b0", x"0e228aeb", x"f1780c81", x"428d3654", x"62293496",
        x"01cf72e5", x"9124a012"
    );
    
    type X_array_type is array (0 to 7) of w128;
    constant X_array : X_array_type := (
        x"89ABCDEFFEDCBA987654321027FAD345", x"FEDCBA987654321027FAD345A18B4CB2",
        x"27dac07f42dd0f19b8a5da02907127fa", x"8b952b83d42b7c592ffc5831f69e6888",
        x"af2432c4ed1ec85e55a3ba22124b18aa", x"6ae7725ff4cba1f91dcdfa102ff60603",
        x"eff24fdc6fe46b75893450ad7b938f4c", x"536e424686b3e94fd206965e681edf34"
    );
    
begin

    process
    begin
        -- Initial plaintext
        F_in <= plaintext;
        wait for 10 ns;

        -- Apply round keys and verify intermediate values
        for i in 0 to 1 loop
            rk <= rk_array(i);
            wait for 10 ns;
            F_out <= F(F_in, rk);
            wait for 10 ns;
            report "Test Vector : F_out = " & to_hstring(F_out);
            assert F_out = X_array(i) report "Mismatch in round " & integer'image(i) severity failure;
            F_in <= F_out;
        end loop;

        report "All tests passed!";
        wait;
    end process;

end architecture behavior;
