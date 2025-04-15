# Use a base image with a minimal Linux distribution (Ubuntu in this case)
FROM ubuntu:20.04

# Set environment variables to non-interactive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for OTAWA
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    flex \
    bison \
    libxml2-dev \
    libxslt-dev \
    git \
    ocaml \
    wget \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create the directories for BUILD_DIR and INSTALL_DIR
RUN mkdir -p /opt/otawa_build && mkdir -p /opt/otawa_install

# Set the working directory to BUILD_DIR
WORKDIR /opt/otawa_build

# Clone and build gel
RUN git clone https://git.renater.fr/anonscm/git/otawa/gel.git && \
    cd gel && \
    cmake . -DCMAKE_INSTALL_PREFIX=/opt/otawa_install && \
    make install

# Clone and build elm
RUN git clone https://git.renater.fr/anonscm/git/elm/elm.git && \
    cd elm && \
    cmake . -DCMAKE_INSTALL_PREFIX=/opt/otawa_install && \
    make install

# Clone and build gelpp
RUN git clone https://git.renater.fr/anonscm/git/otawa/gelpp.git && \
    cd gelpp && \
    cmake . -DCMAKE_INSTALL_PREFIX=/opt/otawa_install && \
    make install

# Clone and build otawa
RUN git clone https://git.renater.fr/anonscm/git/otawa/otawa.git && \
    cd otawa && \
    cmake . -DCMAKE_INSTALL_PREFIX=/opt/otawa_install && \
    make install

# Set the environment path for OTAWA executables and libraries
RUN echo 'export PATH=$PATH:/opt/otawa_install/bin' >> /etc/profile

# Clone micro-architecture (example: lpc2138 ARM)
RUN git clone https://git.renater.fr/anonscm/git/otawa/lpc2138.git && \
    cd lpc2138 && \
    cmake . && \
    make install

# Install gliss2 loader (example: arm)
RUN git clone https://git.renater.fr/anonscm/git/gliss2/gliss2.git && \
    cd gliss2 && \
    make && \
    cd .. && \
    git clone https://git.renater.fr/anonscm/git/gliss2/armv5t.git && \
    cd armv5t && \
    make WITH_DYNLIB=1 && \
    cd .. && \
    git clone https://git.renater.fr/anonscm/git/otawa/otawa-arm.git && \
    cd otawa-arm && \
    cmake . && \
    make install

# Install a plug-in (example: otawa-clp)
RUN git clone https://git.renater.fr/anonscm/git/otawa/otawa-clp.git && \
    cd otawa-clp && \
    cmake . && \
    make install

# Install oRange tool
RUN git clone https://git.renater.fr/anonscm/git/orange/Frontc.git && \
    cd Frontc && \
    make && \
    cd .. && \
    git clone https://git.renater.fr/anonscm/git/orange/orange.git && \
    cd orange && \
    make install ONLY_APP=1 PREFIX=/opt/otawa_install

# Set environment variables for the container
ENV PATH="/opt/otawa_install/bin:${PATH}"

# Set the working directory for the container
WORKDIR /opt/otawa_install

# Define the entrypoint (in case the container is used to invoke OTAWA commands)
ENTRYPOINT ["/bin/bash"]
