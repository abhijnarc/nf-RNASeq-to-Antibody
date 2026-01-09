FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    wget unzip build-essential default-jre \
    gcc make zlib1g-dev libncurses5-dev libbz2-dev liblzma-dev \
    git curl rsync bash coreutils procps \
    && rm -rf /var/lib/apt/lists/*

# Install python libs
RUN pip3 install pandas biopython

# Install fastp (example)
RUN apt-get update && apt-get install -y cmake libz-dev libbz2-dev liblzma-dev libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

# You should install TRUST4, mmseqs2, igblast and RIOT here.
# Example placeholders - for reproducible image you should download & install specific releases
# e.g: install mmseqs2 from apt or build from binary package
# COPY local binaries if you have them:
# COPY Tools/ mmseqs2/ trust4/ igblast/ riot/ /usr/local/bin/

WORKDIR /app
COPY bin/ /app/bin
RUN chmod +x /app/bin/*

ENV PATH="/app/bin:${PATH}"
