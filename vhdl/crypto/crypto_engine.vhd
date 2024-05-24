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
    variable i: integer range 0 to 31;
    variable j: integer range 0 to 31;
    signal mux_key_en: std_ulogic; -- Key multiplexer input selection
    signal mux_key_out: w128; -- Key multiplexer output
    signal key_reg: w128; -- Key registry
    signal mux_data_en: std_ulogic; -- Data multiplexer input selection
    signal mux_data_out: w128; -- Data multiplexer output
    signal data_reg: w128; -- Data registry
    signal w_en_data: std_ulogic; -- Data registry write-enable signal

    type type_state is (Idle0, Enc_init, Enc_round, Enc_end, Dec_init, Dec_keygen, Dec_keyreset, Dec_round, Dec_end);
    signal CS, NS: type_state;
begin
    -- Key expansion multiplexer
    mux_key_out <= compute_initials_rks(key) when mux_key_en = '0' else compute_next_rki(data_reg, i);

    -- Round data multiplexer
    mux_data_out <= p when mux_data_en = '0' else F(data_reg, key_reg(127 downto 96));

    write_reg: process(clk) -- Registers actualization process
    begin
        if rising_edge(clk) then
            if sresetn = '0' then
                key_reg <= (others => '0');
                data_reg <= (others => '0');
            else
                key_reg <= mux_key_out;

                if w_en_data = '1' then
                    data_reg <= mux_data_out;
                end if;
            end if;
        end if;
    end process write_reg;

    c <= R(data_reg);

    -- Final state machine

    seq0: process(clk) --Sequential process
    begin
        if (rising_edge(clk)) then
            if(sresetn = '0') then
                CS <= Idle0;
            else
                CS <= NS;
            end if;
        end if;
    end process seq0;

    com0: process(CS, go, dec, i, j) -- Commutarial process
    begin
        w_en_data <= '0';
        mux_key_en <= '0';
        mux_data_en <= '0';
        done <= '0'
        case CS is
            when Idle0 =>
                i := 0;
                j := 31;
                if go = '1' and dec = '0' then
                    NS <= Enc_init;
                    w_en_data <= '1';
                elsif go = '1' and dec = '1' then
                    NS <= Dec_init;
                    w_en_data <= '1'
                else
                    NS <= Idle0;
                end if;

            -- Encryption flow
            when Enc_init =>
                NS <= Enc;
                mux_key_en <= '1';
                mux_data_en <= '1';
                w_en_data <= '1';
                i := i + 1;
            when Enc_round =>
                if i = 31 then
                    NS <= Enc_end;
                    done <= '1';
                else
                    NS <= Enc;
                    mux_key_en <= '1';
                    mux_data_en <= '1';
                    w_en_data <= '1';
                    i := i + 1;
                end if;
            when Enc_end =>
                NS <= Enc_end;
                done <= '1';
            
            -- Decryption flow
            when Dec_init =>
                NS <= Dec_keygen;
                mux_key_en <= '1';
                i := i + 1;
            when Dec_keygen =>
                if i = j then
                    NS <= Dec_round;
                    mux_data_en <= '1';
                    w_en_data <= '1';
                    i := 0;
                else
                    NS <= Dec_keygen;
                    mux_key_en <= '1';
                    i := i + 1;
            when Dec_round =>
                if j = 0 then
                    NS <= Enc_end;
                    done <= '1';
                else
                    NS <= Enc_keygen;
                    j := j - 1;
                end if;
            when Dec_end =>
                NS <= Enc_end;
                done <= '1';
        end case;

    end process com0;

    
end architecture rtl;
