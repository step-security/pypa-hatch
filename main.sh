#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PURPLE="\033[1;35m"
RESET="\033[0m"

if [[ "${RUNNER_OS}" == "Windows" ]]; then
  SEP="\\"
else
  SEP="/"
fi
INSTALL_PATH="${RUNNER_TOOL_CACHE}${SEP}.hatch"

get_asset_digest() {
  local asset_name="$1"
  local api_url

  if [[ "${VERSION}" == "latest" ]]; then
    api_url="https://api.github.com/repos/pypa/hatch/releases/latest"
  else
    api_url="https://api.github.com/repos/pypa/hatch/releases/tags/hatch-v${VERSION}"
  fi

  curl -sSL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${api_url}" | \
    python3 -c "
import sys, json
data = json.load(sys.stdin)
for asset in data.get('assets', []):
    if asset['name'] == '${asset_name}':
        digest = asset.get('digest', '')
        if digest.startswith('sha256:'):
            print(digest[7:].zfill(64))
        break
" | tr -d '\r'
}

install_hatch() {
  mkdir -p "${INSTALL_PATH}"
  archive="${INSTALL_PATH}${SEP}$1"

  echo -e "${PURPLE}Downloading Hatch ${VERSION}${RESET}\n"

  expected_digest=$(get_asset_digest "$1")

  if [[ "${VERSION}" == "latest" ]]; then
    curl -sSLo "${archive}" "https://github.com/pypa/hatch/releases/latest/download/$1"
  else
    curl -sSLo "${archive}" "https://github.com/pypa/hatch/releases/download/hatch-v${VERSION}/$1"
  fi

  if [[ -n "${expected_digest}" ]]; then
    actual=$(python3 -c "import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" "${archive}")
    if [[ "${expected_digest}" != "${actual}" ]]; then
      echo "Checksum verification failed for ${archive}"
      exit 1
    fi
    echo "Checksum verification passed for ${archive}"
  fi

  if [[ "${archive}" =~ \.zip$ ]]; then
    if [[ "${RUNNER_OS}" == "Windows" ]]; then
      7z -bso0 -bsp0 x "${archive}" -o"${INSTALL_PATH}"
    else
      unzip "${archive}" -d "${INSTALL_PATH}"
    fi
  else
    tar -xzf "${archive}" -C "${INSTALL_PATH}"
  fi
  rm "${archive}"

  echo -e "${PURPLE}Installing Hatch ${VERSION}${RESET}"
  "${INSTALL_PATH}${SEP}hatch" --version
  "${INSTALL_PATH}${SEP}hatch" self cache dist --remove

  echo "${INSTALL_PATH}" >> "${GITHUB_PATH}"
}

fallback_install_hatch() {
  echo -e "${PURPLE}Installing Hatch ${VERSION}${RESET}"
  if [[ "${VERSION}" == "latest" ]]; then
    pipx install --pip-args=--upgrade hatch
  else
    pipx install "hatch==${VERSION}"
  fi

  hatch --version
}

if [[ "${RUNNER_OS}" == "Linux" ]]; then
  if [[ "${RUNNER_ARCH}" == "X64" ]]; then
    install_hatch "hatch-x86_64-unknown-linux-gnu.tar.gz"
  elif [[ "${RUNNER_ARCH}" == "ARM64" ]]; then
    install_hatch "hatch-aarch64-unknown-linux-gnu.tar.gz"
  else
    fallback_install_hatch
  fi
elif [[ "${RUNNER_OS}" == "Windows" ]]; then
  if [[ "${RUNNER_ARCH}" == "X64" ]]; then
    install_hatch "hatch-x86_64-pc-windows-msvc.zip"
  else
    fallback_install_hatch
  fi
elif [[ "${RUNNER_OS}" == "macOS" ]]; then
  if [[ "${RUNNER_ARCH}" == "ARM64" ]]; then
    install_hatch "hatch-aarch64-apple-darwin.tar.gz"
  elif [[ "${RUNNER_ARCH}" == "X64" ]]; then
    install_hatch "hatch-x86_64-apple-darwin.tar.gz"
  else
    fallback_install_hatch
  fi
else
  fallback_install_hatch
fi
