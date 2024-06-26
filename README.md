# Dockerfile to build spdk benchmark env

Seal spdk env to docker container.

**WARNING: This image only tested of the local disk.**

# Usage

Build as docker image.
```bash
docker build -t spdk-benchmark -f Dockerfile .
```

Run a container with nvme device, mount /dev/nvme0n1 and /dev/nvme1n1 ssd.
```bash
# Run in frontend
docker run -it --name spdk-benchmark-example \
    --device /dev/nvme0n1 \
    --device /dev/nvme1n1 \
    --privileged \
    -v /lib/modules:/lib/modules \
    -v /dev/hugepages:/dev/hugepages \
    spdk-benchmark \
    /bin/bash
```

# Benchmark

```bash
cd ~
./bind.sh
fio spdk_conv.fio
```

# Knowing issues

Complie with warning ( seem have not any effect ):

```
./include//reg_sizes.asm:358: warning: Unknown section attribute 'note' ignored on declaration of section `.note.gnu.property' [-w+other]
```

# Reference
1. https://spdk.io/doc/containers.html
2. https://github.com/phusion/baseimage-docker/issues/319