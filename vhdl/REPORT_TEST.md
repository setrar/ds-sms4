To compile and run the VHDL testbench, you can use the GHDL tool, which is a popular open-source VHDL simulator. Here are the commands to compile and run the testbench using GHDL:

1. Open a terminal and navigate to the directory containing your VHDL files (`crypto_pkg.vhd` and `tb_F_function.vhd`).

2. Compile the `crypto_pkg` package:
   ```sh
   ghdl -a crypto_pkg.vhd
   ```

3. Compile the testbench:
   ```sh
   ghdl -a tb_F_function.vhd
   ```

4. Elaborate the testbench:
   ```sh
   ghdl -e tb_F_function
   ```

5. Run the simulation:
   ```sh
   ghdl -r tb_F_function --vcd=tb_F_function.vcd
   ```

   This command will also generate a VCD (Value Change Dump) file named `tb_F_function.vcd` which you can use to view the waveform in a waveform viewer like GTKWave.

6. (Optional) View the waveform using GTKWave:
   ```sh
   gtkwave tb_F_function.vcd
   ```

These commands should compile, elaborate, and run your VHDL testbench, and optionally allow you to view the simulation waveforms. Make sure GHDL and GTKWave are installed on your system before running these commands. If they are not installed, you can find installation instructions on their respective websites.