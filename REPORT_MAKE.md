# REPORT

### Compiling when using `Makefile`

```
make crypto_pkg SIM=ghdl
```

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
            $ds_sms4/vhdl/crypto/tb_F_function.vhd
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


# References

