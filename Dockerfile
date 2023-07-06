FROM ubuntu:18.04 as base

ENV DEBIAN_FRONTEND=noninteractive 

# URL of the Action Service server
ARG actionHostname
ARG actionPort

# URL of the Trigger Service server
ARG triggerHostname
ARG triggerPort

RUN apt update
RUN apt install -y sudo autoconf automake autotools-dev bc \
bison build-essential curl expat libexpat1-dev flex gawk gcc git \
gperf libgmp-dev libmpc-dev libmpfr-dev libtool texinfo tmux \
patchutils zlib1g-dev wget bzip2 patch vim-common lbzip2 python3 \
pkg-config libglib2.0-dev libpixman-1-dev libssl-dev screen \
device-tree-compiler expect makeself unzip cpio rsync cmake ninja-build p7zip-full tar

RUN apt install -y autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev wget

#RUN wget https://cmake.org/files/v3.26/cmake-3.26.4-linux-x86_64.tar.gz && tar -xvf cmake-3.26.4-linux-x86_64.tar.gz && ln -sf /build/cmake-3.26.4-linux-x86_64/bin/* /usr/bin/

WORKDIR /build
RUN wget https://cmake.org/files/v3.26/cmake-3.26.4-linux-x86_64.tar.gz && tar -xvf cmake-3.26.4-linux-x86_64.tar.gz && ln -sf /build/cmake-3.26.4-linux-x86_64/bin/* /usr/bin/

#RUN wget https://cmake.org/files/v3.26/cmake-3.26.4-linux-x86_64.tar.gz && tar -xvf cmake-3.26.4-linux-x86_64.tar.gz && ln -sf /build/cmake-3.26.4-linux-x86_64/bin/* /usr/bin/

# Download LLVM 12.0.1 and add to PATH
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz && tar -xvf clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz

ENV PATH="${PATH}:/build/clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-/bin"
RUN cd /build/clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-/bin && ls && echo $PATH

RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain && cd riscv-gnu-toolchain && git checkout 2023.06.09 && mkdir -p build/install && \
cd build && ../configure --prefix=$(pwd)/install && make musl -j$(nproc)

ENV PATH="${PATH}:/build/riscv-gnu-toolchain/build/install/bin"

RUN mkdir -p /build/bin/

RUN git clone https://github.com/deepaksirone/keystone && cd keystone && git checkout tap_test_disk_sz && ./fast-setup.sh

ENV RISCV="/build/keystone/riscv64"
ENV PATH="/build/keystone/riscv64/bin:${PATH}"
ENV KEYSTONE_SDK_DIR="/build/keystone/sdk/build64"

# Build static_script_runtime
RUN git clone https://github.com/deepaksirone/static_script_runtime && cd static_script_runtime && git checkout master && \
mkdir -p build && cd build && cmake .. && make

ENV RULE_SHIM_DIR="/build/static_script_runtime/build"

# Build StaticScript
RUN apt install -y nodejs npm
RUN git clone https://github.com/deepaksirone/StaticScript && cd StaticScript && git checkout e0bd9ef5b5b4f0e4d55110b2c50d32ea5d5d2a8c && npm install -g n && n 14.18.2 && \
npm install --global yarn && yarn install && yarn run build

ENV PATH="/build/StaticScript/bin:${PATH}"

# Build TAP Cryptor
RUN git clone https://github.com/deepaksirone/rule-cryptor.git && cd rule-cryptor && git checkout artifact && ./build.sh

ENV PATH="/build/rule-cryptor/:${PATH}"
ENV TAP_CRYPTOR_DIR="/build/rule-cryptor/"

#COPY ./ntp_client.ke ./keystore.ke /build/bin/
#COPY ./out/* /build/bin/
# TODO: Have a separate target for all the benchmark programs
RUN cd keystone && mkdir -p build/ && cd build && cmake .. && make all -j$(nproc) && make examples 

ENV RULE_LIB_DIR="/build/tap-apps/benchmark_applets/output/"

RUN git clone https://github.com/deepaksirone/tap-apps && cd tap-apps && git checkout artifact && mkdir -p build && cd build && cmake .. && make tap-programs && cp /build/tap-apps/build/src/ntp_client/ntp_client.ke /build/tap-apps/build/src/keystore/keystore.ke /build/bin/ && make clean

# Patch encrypted_rule
#RUN cd tap-apps && sed -i "270s/.*/     http::Request request{\"http:\/\/$triggerHostname:$triggerPort\/event_data\/\"};/" src/encrypted_rule/host/enclave-host.cpp
#RUN cd tap-apps && sed -i "13s/.*/    #define RULE_ACTION_PARAMS_UNESCAPED { \"{ \\\\\"attrib1\\\\\" : \\\\\"val1\\\\\", \\\\\"attrib2\\\\\" : \\\\\"val2\\\\\", \\\\\"action_url\\\\\": \\\\\"http:\/\/$actionHostname:$actionPort\/action_data\/\\\\\", \\\\\"action_id\\\\\": \\\\\"0\\\\\" }\",}/" src/encrypted_rule/eapp/rule_params.h

# Patch rule_process
#RUN cd tap-apps && sed -i "289s/.*/     http::Request request{\"http:\/\/$triggerHostname:$triggerPort\/event_data\/\"};/" src/rule_process/host/enclave-host.cpp
#RUN cd tap-apps && sed -i "13s/.*/    #define RULE_ACTION_PARAMS_UNESCAPED { \"{ \\\\\"attrib1\\\\\" : \\\\\"val1\\\\\", \\\\\"attrib2\\\\\" : \\\\\"val2\\\\\", \\\\\"action_url\\\\\": \\\\\"http:\/\/$actionHostname:$actionPort\/action_data\/\\\\\", \\\\\"action_id\\\\\": \\\\\"0\\\\\" }\",}/" src/rule_process/eapp/rule_params.h

RUN wget https://cmake.org/files/v3.26/cmake-3.26.4-linux-x86_64.tar.gz && tar -xvf cmake-3.26.4-linux-x86_64.tar.gz && ln -sf /build/cmake-3.26.4-linux-x86_64/bin/* /usr/bin/
RUN mkdir -p /build/bin/benchmark_applets_prebuilt
RUN cd tap-apps && ./build-benchmark-applets.sh $(pwd)/benchmark_applets /build/bin/benchmark_applets_prebuilt $triggerHostname $triggerPort $actionHostname $actionPort

# Build tap_client
RUN git clone https://github.com/deepaksirone/tap-client/ && cd tap-client && git checkout artifact_riscv && mkdir -p build && cd build && cmake .. && make && \
cp tap_client ../reg_user.txt ../reg_rule.txt /build/bin

#COPY ./out/* /build/bin/
RUN cd keystone/build && cp -r /build/bin/* ./overlay/root/ && make image -j$(nproc) && make tools


#RUN echo "export HOST_PORT=${HOST_PORT:="$((3000 + RANDOM % 3000))"};       echo "**** Running QEMU SSH on port ${HOST_PORT} ****";       export SMP=1;       while [ "$1" != "" ]; do if [ "$1" = "-debug" ]; then echo "**** GDB port $((HOST_PORT + 1)) ****"; DEBUG="-gdb tcp::$((HOST_PORT + 1)) -S -d in_asm -D debug.log"; fi; if [ "$1" = "-smp" ]; then SMP="$2"; shift; fi; shift; done;       /build/keystone/qemu/riscv64-softmmu/qemu-system-riscv64       $DEBUG       -m 2G       -nographic       -machine virt       -bios /build/keystone/build/bootrom.build/bootrom.bin       -kernel /build/keystone/build/sm.build/platform/generic/firmware/fw_payload.elf             -append "console=ttyS0 ro root=/dev/vda"       -drive file=/build/keystone/build/buildroot.build/images/rootfs.ext2,format=raw,id=hd0       -device virtio-blk-device,drive=hd0          -netdev user,id=net0,net=192.168.100.1/24,dhcpstart=192.168.100.128,hostfwd=tcp::${HOST_PORT}-:22       -device virtio-net-device,netdev=net0       -device virtio-rng-pci       -smp $SMP"

RUN cd keystone/build/scripts && echo "#!/bin/bash \n\
      export HOST_PORT=\${HOST_PORT:=\"7022\"}; \
      echo \"**** Running QEMU SSH on port \${HOST_PORT} ****\"; \
      export SMP=1; \
      while [ \"\$1\" != \"\" ]; do if [ \"\$1\" = \"-debug\" ]; then echo \"**** GDB port \$((HOST_PORT + 1)) ****\"; DEBUG=\"-gdb tcp::\$((HOST_PORT + 1)) -S -d in_asm -D debug.log\"; fi; if [ \"\$1\" = \"-smp\" ]; then SMP=\"\$2\"; shift; fi; shift; done; \
      /build/keystone/qemu/riscv64-softmmu/qemu-system-riscv64 \
      \$DEBUG \
      -m 2G \
      -nographic \
      -machine virt \
      -bios /build/keystone/build/bootrom.build/bootrom.bin \
      -kernel /build/keystone/build/sm.build/platform/generic/firmware/fw_payload.elf \
      -append \"console=ttyS0 ro root=/dev/vda\"       -drive file=/build/keystone/build/buildroot.build/images/rootfs.ext2,format=raw,id=hd0       -device virtio-blk-device,drive=hd0 \
      -netdev user,id=net0,net=192.168.100.1/24,dhcpstart=192.168.100.128,hostfwd=tcp::7022-:22,hostfwd=tcp::7080-:80,hostfwd=tcp::7777-:7777 \
      -device virtio-net-device,netdev=net0 \
      -device virtio-rng-pci \
      -smp \$SMP" > run-qemu.sh
RUN chmod +x /build/keystone/build/scripts/run-qemu.sh && sed  -i '1i #!/bin/bash' /build/keystone/build/scripts/run-qemu.sh
ENV PATH="/build/keystone/build/scripts/:${PATH}"

CMD ["run-qemu.sh"]