# chipyard-env

This repo contains a `Dockerfile` for a container that builds [chipyard](https://github.com/ucb-bar/chipyard), an open-source framework for developing RISC-V chips using Chisel. 

To build the Docker container, first clone the repository and navigate to it. Then:
```bash
$ docker build -t chipyard-env .
```

The first time it builds will take a long time, as it needs to build all of the chipyard dependencies in addition to the RISC-V GNU toolchain. Once the container is built, you can start an interactive session:
```bash
$ docker run -it chipyard-env
```

Before using chipyard to synthesize any designs, make sure to source the setup script:
```bash
$ source ./env.sh
```

Then you can synthesize designs in the chipyard repo. Below is an example for synthesizing BOOM, the Berkeley out-of-order machine.
```bash
$ cd sims/verilator
$ make CONFIG=SmallBoomConfig
```
