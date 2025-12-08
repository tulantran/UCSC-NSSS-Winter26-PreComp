# Compiling HPL on Hummingbird

This guide serves to get you started on compiling HPL on UCSC's own supercomputing cluster, Hummingbird. Firstly, you need to connect to Hummingbird. Use

```
ssh cruzid@hb.ucsc.edu
```
and login with your cruzid password to login to Hummingbird. Now, you should be logged in to Hummingbird!

To start compiling HPL, you first need its source code. You can find it [here](https://www.netlib.org/benchmark/hpl/). Use
```
wget "https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz"
```
to download it directly to the machine. Once you have the source code, use the `tar` command to untar the the downloaded file. You should end up with a directory called `hpl-2.3`. You then need to get its dependencies.