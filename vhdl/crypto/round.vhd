library ieee;
use ieee.std_logic_1164.all;

use work.crypto_pkg.all;

entity round is
    port (
        rk: in zi; -- Round key
        permut_in: in w128; -- Input 128-bit vector
        permut_out: out w128; -- Output 128-bit vector
    );
end entity round;

architecture rtl of round is
    signal cnt: natural range 0 to f_mhz;
    signal next_cnt: natural range 0 to f_mhz;
    signal next_t: natural range 0 to max_us;
begin
    
end architecture rtl;