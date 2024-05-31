# REPORT

### Compiling when using `Makefile`

```
make crypto_pkg SIM=ghdl
```

### Compiling indivual files

---

- [ ] Source Home

DS_HOME=~/Developer/ds-sms4

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


# References

