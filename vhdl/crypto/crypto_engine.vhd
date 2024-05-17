library ieee;
use ieee.std_logic_1164.all;

use work.crypto_pkg.all;

entity crypto_engine is
    port (
        clk: in std_ulogic; -- Clock signal input
        sresetn: in std_ulogic; -- Reset signal input
        go: in std_ulogic; -- Start signal input
        dec: in std_ulogic; -- Input signal to use the engine in ecryption or decryption mode
        key: in w128; -- 128 bit encryption key input
        p: in w128; -- 128 plain text input
        done: out std_ulogic; -- Signal used to tell when the encryption/decryption is done
        c: out w128 -- ciphertext output
    );
end entity crypto_engine;

architecture rtl of crypto_engine is
    signal i: integer range 0 to 31;
    signal mux_key_en: std_ulogic;
    signal mux_key_out: w128;
    signal key_reg: w128;
    signal mux_data_en: std_ulogic;
    signal mux_data_out: w128;
    signal data_reg: w128;
    signal w_en_key: std_ulogic;
    signal w_en_data: std_ulogic;
begin
    -- Key expansion multiplexer
    mux_key_out <= compute_initials_rks(key) when mux_key_en = '0' else compute_next_rki(data_reg, i);

    -- Round data multiplexer
    mux_data_out <= p when mux_data_en = '0' else F(data_reg, key_reg(127 downto 96));

    write_reg: process(clk) -- Registries actualization process
    begin
        if rising_edge(clk) then
            if sresetn = '0' then
                key_reg <= (others => '0');
                data_reg <= (others => '0');
            else
                if w_en_key = '1' then
                    key_reg <= mux_key_out;
                end if;

                if w_en_data = '1' then
                    data_reg <= mux_data_out;
                end if;
            end if;
        end if;
    end process write_reg;

    c <= R(data_reg);

    
end architecture rtl;
