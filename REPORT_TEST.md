
### Compiling indivual files

---

- [ ] Source Home

```
DS_HOME=~/Developer/ds-sms4
```

- [ ] Source binaries

```
. $DS_HOME/bin/source.sh
```

```
cd "$sim"
```



- [ ] Synthesizing

* Analyzing (can also use -a parameter)

```
ghdl analyse --std=08 \
            $ds_sms4/vhdl/crypto/crypto_pkg.vhd \
            $ds_sms4/vhdl/ut/tb_F_function.vhd
```

* Running (can also use -r parameter)


- [ ] Visualizing

    ```sh
    ghdl run --std=08 tb_F_function --vcd=tb_F_function.vcd
    ```
> Returns
```powershell
.../vhdl/crypto/tb_F_function.vhd:29:9:@20ns:(report note): Test Vector 1: F_out = 89ABCDEF0123456789ABCDEF5659CAC8
.../vhdl/crypto/tb_F_function.vhd:39:9:@40ns:(report note): Test Vector 2: F_out = 76543210FEDCBA98765432102FD7A94F
```

```
gtkwave tb_F_function.vcd
```
> Returns
```powershell
GTKWave Analyzer v3.4.0 (w)1999-2022 BSI

[0] start time.
[40000000] end time.
```

<img src=images/tb_F_function_1.png width='' height='' > </img>

---

To compile and run the VHDL testbench, you can use the GHDL tool, which is a popular open-source VHDL simulator. Here are the commands to compile and run the testbench using GHDL:

1. Open a terminal and navigate to the directory containing your VHDL files (`crypto_pkg.vhd` and `tb_F_function.vhd`).

2. Compile the `crypto_pkg` package along with the testbench:

   ```
   ghdl analyse --std=08 \
               $ds_sms4/vhdl/crypto/crypto_pkg.vhd \
               $ds_sms4/vhdl/crypto/tb_F_function_round1.vhd
   ```

5. Run the simulation:
   ```sh
   ghdl run --std=08 tb_F_function_round1 --vcd=tb_F_function_round1.vcd
   ```
> Returns:
```powershell
.../vhdl/crypto/tb_F_function_round1.vhd:34:9:@20ns:(report note): Test Vector 1: F_in = 0123456789ABCDEFFEDCBA9876543210
.../vhdl/crypto/tb_F_function_round1.vhd:35:9:@20ns:(report note): Test Vector 1: F_out = 89ABCDEFFEDCBA987654321027FAD345
.../vhdl/crypto/tb_F_function_round1.vhd:48:9:@40ns:(report note): Test Vector 2: F_in = 89ABCDEFFEDCBA987654321027FAD345
.../vhdl/crypto/tb_F_function_round1.vhd:49:9:@40ns:(report note): Test Vector 2: F_out = FEDCBA987654321027FAD345A18B4CB2
```

   This command will also generate a VCD (Value Change Dump) file named `tb_F_function_round1.vcd` which you can use to view the waveform in a waveform viewer like GTKWave.

6. (Optional) View the waveform using GTKWave:
   ```sh
   gtkwave tb_F_function_round1.vcd
   ```
   >Returns:
```powershell

GTKWave Analyzer v3.4.0 (w)1999-2022 BSI

[0] start time.
[40000000] end time.
```

<img src=images/tb_F_function_round1.png width='' height='' > </img>


These commands should compile, elaborate, and run your VHDL testbench, and optionally allow you to view the simulation waveforms. Make sure GHDL and GTKWave are installed on your system before running these commands. If they are not installed, you can find installation instructions on their respective websites.

- [ ] Mismatch

   ```
   ghdl analyse --std=08 \
               $ds_sms4/vhdl/crypto/crypto_pkg.vhd \
               $ds_sms4/vhdl/crypto/tb_F_function_mismatch.vhd
   ```

   ```
   ghdl run --std=08 tb_F_function_mismatch --vcd=tb_F_function_mismatch.vcd
   ```
   > 
   ```powershell
   .../vhdl/crypto/tb_F_function_mismatch.vhd:50:13:@30ns:(report note): Test Vector : F_out = 89ABCDEF0123456789ABCDEF27FAD345
   .../vhdl/crypto/tb_F_function_mismatch.vhd:51:13:@30ns:(assertion failure): Mismatch in round 0
   ghdl:error: assertion failed
   ghdl:error: simulation failed
   ```

   :x: Not complete