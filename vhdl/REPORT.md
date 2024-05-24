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



- [ ] Synthesizing

* Analyzing (can also use -a parameter)

```
ghdl analyse --std=08 --work=common $ds_sms4/vhdl/common/axi_pkg.vhd "$ds_sms4/vhdl/crypto/crypto_pkg.vhd" "$ds_sms4/vhdl/crypto/tb_F_function.vhd"
```

* Running (can also use -r parameter)


- [ ] Visualizing


# References

