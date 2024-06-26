FROM ubuntu:latest
MAINTAINER zhiweizhang "zhiwayzhang@outlook.com"

# Setup ENV
ENV HOME=/root
ENV PATH_TO_FIO=/root/fio
ENV RELEASE_FIO=fio-3.36
ENV PATH_TO_SPDK=/root/spdk
ENV PLUGIN_BDEV_PATH=/root/spdk/build/fio/spdk_bdev
ENV PLUGIN_NVME_PATH=/root/spdk/build/fio/spdk_nvme
ENV RELEASE_SPDK=v24.05
ENV DEBIAN_FRONTEND=noninteractive

# Check Ubuntu release and update sources.list or ubuntu.sources
RUN . /etc/os-release && \
    if [ "$VERSION_ID" \< "24.04" ]; then \
      echo "Updating sources.list for Ubuntu $VERSION_ID"; \
      sed -i 's@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g' /etc/apt/sources.list; \
    else \
      echo "Updating ubuntu.sources for Ubuntu $VERSION_ID"; \
      sed -i 's@http://archive.ubuntu.com/@http://mirrors.tuna.tsinghua.edu.cn/@g' /etc/apt/sources.list.d/ubuntu.sources; \
    fi

# Prepare
# Ref: https://github.com/phusion/baseimage-docker/issues/319
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y git pkg-config kmod vim

# Clone source code
RUN git clone https://github.com/spdk/spdk --recursive $PATH_TO_SPDK
RUN git clone https://github.com/axboe/fio $PATH_TO_FIO

# Set up dependencies
WORKDIR $PATH_TO_SPDK
RUN git checkout $RELEASE_SPDK
# Or set up with ./scripts/pkgdep.sh --all
RUN ./scripts/pkgdep.sh

# Build fio
WORKDIR $PATH_TO_FIO
RUN git checkout $RELEASE_FIO
RUN ./configure
RUN make -j
RUN make install

# Build spdk
WORKDIR $PATH_TO_SPDK
# Add configuration flags as your need
RUN ./configure --with-fio=$PATH_TO_FIO
RUN make -j

# Check
RUN if [ -f $PLUGIN_BDEV_PATH ]; then \
        echo "File exists. Continuing with build..."; \
    else \
        echo "Error: build/fio/spdk_bdev not found." >&2; \
        exit 1; \
    fi
RUN if [ -f $PLUGIN_NVME_PATH ]; then \
        echo "File exists. Continuing with build..."; \
    else \
        echo "Error: build/fio/spdk_nvme not found." >&2; \
        exit 1; \
    fi

RUN echo "Build Success."

COPY *.fio *.sh /root/

RUN echo "COPY benchmark examples to /root."

WORKDIR $HOME

CMD ["bash"]