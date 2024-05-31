# REPORT


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



### Compiling when using `Makefile`



```
make crypto_pkg SIM=ghdl
```

```
make crypto_bench SIM=ghdl
```


# References

- [ ] Compile

```
make crypto_bench
```

- [ ] Using ModelSim

Make sure `ModelSim` is on your path

```
export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
```

- [ ] Run the simulation

```
make crypto_bench.sim
```

