# REPORT

### Compiling when using `Makefile`

```
make crypto_pkg SIM=ghdl
```

### Compiling indivual files

---

- [ ] Source binaries

```
. ~/Developer/ds-sms4/bin/source.sh
```

```
cd "$sim"
```

```
ghdl -a --std=08 --work=common "$ds-sms4/vhdl/common/rnd_pkg.vhd"
```

```
ghdl -a --std=08 --work=axi_pkg "$ds-sms4/vhdl/common/axi_pkg.vhd"
```


- [ ] Synthesizing

* Analyzing (can also use -a parameter)

```
ghdl analyse --std=08 "$ds-sms4/vhdl/crypto/crypto.vhd" "$ds-sms4/vhdl/crypto/crypto_sim.vhd"
```

* Running (can also use -r parameter)

```
ghdl run --std=08 crypto_sim --vcd=crypto_sim.vcd
```
> simulation finished @2019ns

- [ ] Visualizing

```
gtkwave crypto_sim.vcd
```
> Returns
```powershell
GTKWave Analyzer v3.3.114 (w)1999-2023 BSI

[0] start time.
[2018000000] end time.
```

<img src=images/timer_sim.png width='' height='' > </img>


# References

