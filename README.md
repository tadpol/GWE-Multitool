# Gateway Engine Multitool

A [Murano](https://exosite.com/platform/) Solution for quickly getting data visualized.


## Install

This solution uses the [MrMurano](https://github.com/tadpol/MrMurano#mrmurano) tool
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
mr config solution.id XXXXX
mr syncup -V
```

After creating you product, you can push up the resource specification:

```
mr config product.id YYYYYYYYYY
mr product spec --file spec/gwe-multitool.yaml
```

Then connect the two.

```
mr assign set -V
```

## Freeboard

GWEMT uses a fork of [Freeboard](https://github.com/Freeboard/freeboard) that
preloads datasources and does save/load of a dashboard.  The compiled output is in
`files/` and can be synced into Murano without changes.

