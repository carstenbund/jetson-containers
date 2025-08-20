#!/usr/bin/env bash
# launcher for jetson_containers/build.py (see docs/build.md)

set -euo pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
VENV="$ROOT/venv"

# always run from repo root
cd "$ROOT"

# load venv if present
if [ -d "$VENV" ]; then
  . "$VENV/bin/activate"
fi

# load env files if present
for envfile in .env .env.local; do
  if [ -f "$envfile" ]; then
    set -a
    . "$envfile"
    set +a
  fi
done

# collect build args into a single comma-separated string
BUILD_ARGS_LIST=()
add_build_arg() {
  local k="$1"
  local v="${!k:-}"
  if [ -n "$v" ]; then
    BUILD_ARGS_LIST+=("${k}:${v}")
  fi
}

for k in L4T_TAG UBUNTU_VERSION CUDA_VERSION CUDA_TAG PYTHON_VERSION PIP_INDEX_URL PIP_EXTRA_INDEX_URL; do
  add_build_arg "$k"
done

BUILD_ARGS_STR=""
if [ "${#BUILD_ARGS_LIST[@]}" -gt 0 ]; then
  BUILD_ARGS_STR="$(printf '%s,' "${BUILD_ARGS_LIST[@]}")"
  BUILD_ARGS_STR="${BUILD_ARGS_STR%,}"   # trim trailing comma
fi

# compose python command
CMD=( python3 -m jetson_containers.build )

if [ -n "$BUILD_ARGS_STR" ]; then
  CMD+=( --build-args "$BUILD_ARGS_STR" )
fi

# only add --build-flags if provided
if [ -n "${DOCKER_BUILD_ARGS:-}" ]; then
  CMD+=( --build-flags "$DOCKER_BUILD_ARGS" )
fi

# pass through positional package args (e.g., "ollama")
CMD+=( "$@" )

# debug: uncomment if you want to see the full command echoed
# echo ">> ${CMD[*]}"

PYTHONPATH="$PYTHONPATH:$ROOT" "${CMD[@]}"
