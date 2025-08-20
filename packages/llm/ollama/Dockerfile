#---
# name: ollama
# group: llm
# config: config.py
# depends: [cuda, python]
# requires: '>=34.1.0'
# docs: docs.md
# test: test.sh
#---
ARG L4T_TAG
FROM nvcr.io/nvidia/l4t-base:${L4T_TAG}

ARG OLLAMA_VERSION \
    JETPACK_VERSION_MAJOR \
    PIP_INDEX_URL \
    PIP_EXTRA_INDEX_URL \
    TMP=/tmp/ollama

ENV OLLAMA_VERSION=${OLLAMA_VERSION} \
    OLLAMA_HOST=0.0.0.0 \
    OLLAMA_LOGS=/data/logs/ollama.log \
    OLLAMA_MODELS=/data/models/ollama/models \
    PIP_INDEX_URL=${PIP_INDEX_URL} \
    PIP_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL} \
    CUDAToolkit_ROOT=/usr/local/cuda-11.4 \
    CUDACXX=/usr/local/cuda-11.4/bin/nvcc \
    LD_LIBRARY_PATH=/usr/local/cuda/targets/aarch64-linux/lib:/usr/lib/aarch64-linux-gnu/tegra:$LD_LIBRARY_PATH \
    OLLAMA_RUNNERS_DIR=/opt/runners

RUN apt-get update && apt-get install -y --no-install-recommends git cmake build-essential \
 && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://bootstrap.pypa.io/pip/3.8/get-pip.py | python3 \
 && python3 -m pip install --no-cache-dir "pip<25.1" "setuptools<70" "wheel<0.45"

RUN git clone --depth=1 https://github.com/ggerganov/llama.cpp /opt/llama.cpp \
 && cmake -S /opt/llama.cpp -B /opt/llama.cpp/build -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=72 -DCMAKE_BUILD_TYPE=Release \
 && cmake --build /opt/llama.cpp/build -j \
 && install -s /opt/llama.cpp/build/bin/llama /usr/local/bin/llama \
 && mkdir -p /opt/runners \
 && ln -sf /usr/local/bin/llama /opt/runners/llama

COPY nv_tegra_release /etc/nv_tegra_release

COPY install.sh $TMP/
RUN $TMP/install.sh

COPY start_ollama /
CMD /start_ollama && /bin/bash

EXPOSE 11434
