# JetPack 5 / CUDA 11.4 Audit

## Findings
- **build.sh** only loaded `.env` and didn't forward environment overrides or custom build flags. Added loading for `.env.local`, construction of `--build-args` for `L4T_TAG`, `UBUNTU_VERSION`, `CUDA_VERSION`, `CUDA_TAG`, `PYTHON_VERSION`, `PIP_INDEX_URL`, and `PIP_EXTRA_INDEX_URL`, and forwarding of `${DOCKER_BUILD_ARGS}` to `docker build`.
- **packages/llm/ollama/Dockerfile** was implicitly tied to JetPack 6 and CUDA 12 via its base image and lack of runner build. Updated to parameterize the base image via `L4T_TAG`, pin Python 3.8 tooling from upstream PyPI, build a CUDA‑11.4 `llama.cpp` runner (SM72), expose Tegra/CUDA libraries through `LD_LIBRARY_PATH`, and default `OLLAMA_RUNNERS_DIR` to `/opt/runners`.
- Default package docs under `packages/llm/ollama/` referenced JetPack 6 (`r36.*`). For JetPack 5 builds, ensure commands use the `r35.*` tag or omit the version to avoid mismatched examples.

## Changes made
- Added `.env.local` template with JetPack 5 + CUDA 11.4 defaults and upstream pip indices.
- Modified `build.sh` to propagate build arguments and user-provided docker build flags.
- Reworked `packages/llm/ollama/Dockerfile` for JetPack 5 / CUDA 11.4 and local runner integration.

## CUDA‑11.4 build draft
```bash
# env pins for 11.4
export CUDAToolkit_ROOT=/usr/local/cuda-11.4
export CUDACXX=/usr/local/cuda-11.4/bin/nvcc

cd ~/code/llama.cpp
git pull --rebase
rm -rf build && mkdir build && cd build

cmake .. \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES=72 \
  -DCMAKE_CUDA_COMPILER=/usr/local/cuda-11.4/bin/nvcc \
  -DCUDAToolkit_ROOT=/usr/local/cuda-11.4 \
  -DCMAKE_BUILD_TYPE=Release

# sanity: confirm CMake chose 11.4
grep -E 'CUDAToolkit_VERSION|CMAKE_CUDA_COMPILER' CMakeCache.txt

cmake --build . -j
```
