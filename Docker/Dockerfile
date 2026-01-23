FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    wget unzip build-essential default-jre \
    gcc make zlib1g-dev libncurses5-dev libbz2-dev liblzma-dev \
    git curl rsync bash coreutils procps \
    && rm -rf /var/lib/apt/lists/*

# Install python libs (including IgFold and ImmunoMatch dependencies)
RUN pip3 install pandas biopython pytorch::pytorch pytorch::pytorch-cuda=11.8 pytorch-lightning \
    dm-tree immuno-match igfold

# Install additional dependencies for structure prediction tools
RUN pip3 install numpy scipy scikit-learn matplotlib seaborn requests

# Install fastp and other bioinformatics tools dependencies
RUN apt-get update && apt-get install -y cmake libz-dev libbz2-dev liblzma-dev libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Nextflow (optional, can be run from host)
RUN curl -fsSL https://get.nextflow.io | bash && \
    mv nextflow /usr/local/bin/ && \
    chmod +x /usr/local/bin/nextflow

# Install TRUST4, mmseqs2, igblast, RIOT binaries
# These should be copied from local or downloaded from releases
# COPY Tools/ mmseqs2/ trust4/ igblast/ riot/ /usr/local/bin/

WORKDIR /app

# Copy pipeline code
COPY bin/ /app/bin
COPY modules/ /app/modules
COPY conf/ /app/conf
COPY references/ /app/references

RUN chmod +x /app/bin/*.sh /app/bin/*.py

# Set up environment
ENV PATH="/app/bin:${PATH}"
ENV PYTHONPATH="/app/bin:${PYTHONPATH}"
