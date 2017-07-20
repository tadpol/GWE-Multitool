# Gateway Engine Multitool

A [Murano](https://exosite.com/platform/) Solution for quickly getting data visualized.


## Install

This solution uses the [MuranoCLI](https://github.com/exosite/MuranoCLI) tool
for syncing into [Murano](https://exosite.com/platform/).

After cloning this repository, you need to update the submodules.

```
git clone https://github.com/tadpol/GWE-Multitool.git
cd GWE-Multitool
git submodule init
git submodule update
```

Now it is ready to be synced up to your solution in Murano.

```
murano init
murano syncup -V 
```

## Freeboard

GWEMT uses a fork of [Freeboard](https://github.com/Freeboard/freeboard) that
preloads datasources and does save/load of a dashboard.  The compiled output is in
`assets/` and can be synced into Murano without changes.

