#!/usr/bin/env bash
# launcher for jetson_containers/build.py (see docs/build.md)
ROOT="$(dirname "$(readlink -f "$0")")"
VENV="$ROOT/venv"

if [ -d "$VENV" ]; then
  source "$VENV/bin/activate"
fi

# Load environment variables from .env and .env.local
for envfile in .env .env.local; do
  if [ -f "$envfile" ]; then
    set -a
    source "$envfile"
    set +a
  fi
done

BUILD_ARGS=""
add_build_arg() {
  local var="$1"
  local val="${!var}"
  if [ -n "$val" ]; then
    [ -n "$BUILD_ARGS" ] && BUILD_ARGS+="," 
    BUILD_ARGS+="$var:$val"
  fi
}

for var in L4T_TAG UBUNTU_VERSION CUDA_VERSION CUDA_TAG PYTHON_VERSION PIP_INDEX_URL PIP_EXTRA_INDEX_URL; do
  add_build_arg $var
done

CMD=(python3 -m jetson_containers.build)
if [ -n "$BUILD_ARGS" ]; then
  CMD+=(--build-args "$BUILD_ARGS")
fi
if [ -n "$DOCKER_BUILD_ARGS" ]; then
  CMD+=(--build-flags "$DOCKER_BUILD_ARGS")
fi
CMD+=("$@")

PYTHONPATH="$PYTHONPATH:$ROOT" "${CMD[@]}"
