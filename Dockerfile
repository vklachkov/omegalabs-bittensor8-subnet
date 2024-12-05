FROM nvcr.io/nvidia/cuda:12.6.3-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install software-properties-common to add repositories
RUN apt-get -y update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get -y update && apt-get install -y \
    python3.11 python3.11-distutils python3.11-venv python3.11-dev \
    git libsndfile1 build-essential ffmpeg libpq-dev \
    pkg-config libmysqlclient-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Update the symbolic link for python to point to python3.11
RUN rm /usr/bin/python3 && \
    ln -s /usr/bin/python3.11 /usr/bin/python3 && \
    ln -s /usr/bin/python3.11 /usr/bin/python

# Install UV
COPY --from=ghcr.io/astral-sh/uv:0.5.6 /uv /uvx /bin/

WORKDIR /app/

# Install python requirements
COPY ./requirements.txt ./requirements.txt
COPY ./requirements_api.txt ./requirements_api.txt

RUN uv pip install -r requirements_api.txt --prerelease=allow --no-cache-dir

COPY . .
RUN uv pip install -e . --no-cache-dir

ENTRYPOINT bash

# Run the miner launch command like this inside the container:
# python -m miner.miner --netuid 1 --wallet.name miner --wallet.hotkey default --logging.debug
