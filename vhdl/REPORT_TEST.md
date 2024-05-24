To compile and run the VHDL testbench, you can use the GHDL tool, which is a popular open-source VHDL simulator. Here are the commands to compile and run the testbench using GHDL:

1. Open a terminal and navigate to the directory containing your VHDL files (`crypto_pkg.vhd` and `tb_F_function.vhd`).

2. Compile the `crypto_pkg` package along with the testbench:

   ```sh
   ghdl analyse --std=08 \                                
            $ds_sms4/vhdl/crypto/crypto_pkg.vhd \
            $ds_sms4/vhdl/crypto/tb_F_function.vhd
   ```

5. Run the simulation:
   ```sh
   ghdl run --std=08 tb_F_function --vcd=tb_F_function.vcd
   ```
> Returns:
```powershell
~/Developer/ds-sms4/vhdl/crypto/tb_F_function.vhd:29:9:@20ns:(report note): Test Vector 1: F_out = 1373CCF60123456789ABCDEF01234567
~/Developer/ds-sms4/vhdl/crypto/tb_F_function.vhd:39:9:@40ns:(report note): Test Vector 2: F_out = C8DECB89FEDCBA9876543210FEDCBA98
```

   This command will also generate a VCD (Value Change Dump) file named `tb_F_function.vcd` which you can use to view the waveform in a waveform viewer like GTKWave.

6. (Optional) View the waveform using GTKWave:
   ```sh
   gtkwave tb_F_function.vcd
   ```
   >Returns:
```powershell
GTKWave Analyzer v3.4.0 (w)1999-2022 BSI

[0] start time.
[40000000] end time.
```

<img src=images/tb_F_function_1.png width='' height='' > </img>


These commands should compile, elaborate, and run your VHDL testbench, and optionally allow you to view the simulation waveforms. Make sure GHDL and GTKWave are installed on your system before running these commands. If they are not installed, you can find installation instructions on their respective websites.