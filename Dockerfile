FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

# Set apt mirror, using NCHC's server
RUN sed -i 's/archive.ubuntu.com/free.nchc.org.tw/g' \
    /etc/apt/sources.list
# Update
RUN apt-get update
RUN apt-get upgrade -y
# Install missing system-tools
RUN apt-get install software-properties-common locales -y
# Set locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install chipyard

# Install build tools
RUN apt-get install -y \
    cmake ninja-build \
    build-essential \
    device-tree-compiler
# Install LLVM toolchain
RUN apt-get install -y clang
# Install python3
RUN apt-get install -y \
    python3 python3-dev \
    python3-pip
# Install common tools
RUN apt-get install -y \
    vim git tmux wget curl p7zip \
    clang-format clang-tidy \
    gdb valgrind fish zsh
# Install oh-my-zsh
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN apt-get update -y
RUN apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
RUN  apt-get install -y build-essential bison flex
RUN  apt-get install -y libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev vim git default-jdk default-jre
# RUN echo "deb https://dl.bintray.com/sbt/debian /" |  tee -a /etc/apt/sources.list.d/sbt.list
# COPY tmp.sh .
# RUN sh -c ./tmp.sh
# RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add
RUN  apt-get update
RUN  apt-get install -y texinfo gengetopt
RUN  apt-get install -y libexpat1-dev libusb-dev libncurses5-dev cmake
RUN  apt-get clean
RUN curl -s -L https://github.com/sbt/sbt/releases/download/v1.9.7/sbt-1.9.7.tgz | tar xvz
RUN mv sbt/bin/sbt /usr/bin
# deps for poky
RUN  apt-get install -y python3.6 patch diffstat texi2html texinfo subversion chrpath git wget
# deps for qemu
RUN  apt-get install -y libgtk-3-dev gettext
# deps for firemarshal
RUN apt-add-repository -y ppa:deadsnakes/ppa
RUN  apt-get update -y
RUN  apt-get install -y python3-pip python3.6-dev rsync libguestfs-tools expat ctags
# install DTC
RUN  apt-get install -y device-tree-compiler
RUN  apt-get install -y verilator
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
    apt-get install -y autoconf automake autotools-dev curl python3 \
        python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk \
        build-essential bison flex texinfo gperf libtool patchutils bc \
        zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev \
        libslirp-dev && \
    apt-get clean
RUN git clone --depth 1 https://github.com/riscv/riscv-gnu-toolchain
WORKDIR /riscv-gnu-toolchain
RUN ./configure --prefix=/opt/riscv
RUN make -j8 linux
WORKDIR /root
RUN curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
RUN bash Miniforge3-$(uname)-$(uname -m).sh -b
RUN /bin/bash -c "source /root/miniforge3/bin/activate && conda init bash"
ENV MINIFORGE_PATH=/root/miniforge3
ENV PATH="${MINIFORGE_PATH}/bin:${PATH}"
SHELL ["/bin/bash", "-c"]
RUN conda install -n base conda-libmamba-solver
RUN conda config --set solver libmamba
RUN conda install -n base conda-lock==1.4.0
RUN git clone https://github.com/ucb-bar/chipyard.git
WORKDIR /root/chipyard
RUN git checkout 1.11.0
RUN ./build-setup.sh riscv-tools -s 4 -s 6 -s 7 -s 8 -s 9
