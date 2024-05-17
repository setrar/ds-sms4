# REPORT

- [ ] Source binaries

```
. ~/Developer/ds/bin/source.sh
```

```
cd "$sim"
ghdl -a --std=08 --work=common "$ds/vhdl/common/rnd_pkg.vhd"
```

- [ ] Synthesizing

* Analyzing (can also use -a parameter)

```
ghdl analyse --std=08 "$ds/vhdl/lab03/timer.vhd" "$ds/vhdl/lab03/timer_sim.vhd"
```

* Running (can also use -r parameter)

```
ghdl run --std=08 timer_sim --vcd=timer_sim.vcd
```
> simulation finished @2019ns

- [ ] Visualizing

```
gtkwave timer_sim.vcd
```
> Returns
```powershell
GTKWave Analyzer v3.3.114 (w)1999-2023 BSI

[0] start time.
[2018000000] end time.
```

<img src=images/timer_sim.png width='' height='' > </img>


# References

