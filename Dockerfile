# The god-server runner image: GitHub's official runner image plus the GitHub CLI.
# Built only by .github/workflows/build.yml on GitHub's machines (god-server §5.4: no builds on the server).
# Dependabot moves the FROM line (tag and digest together).
FROM ghcr.io/actions/actions-runner:2.338.2@sha256:759a1d94a15b05941aba5196974ff43fe15b4cbba29b694b35cbc32a1166b232

# GitHub CLI: a pinned release, checked against its published SHA-256 (gh_<v>_checksums.txt).
# To move it: change both lines, from https://github.com/cli/cli/releases.
ARG GH_VERSION=2.103.3
ARG GH_SHA256=4c806978ffce1cec70853302a56d70ac6da4f19bae7adca4e1a8ab00633dd91d

USER root
# Ubuntu security fixes since the base image was built, so the weekly rebuild stays current.
RUN apt-get update \
 && apt-get -y upgrade \
 && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    f="gh_${GH_VERSION}_linux_amd64.tar.gz"; \
    curl -fsSL -o "/tmp/$f" "https://github.com/cli/cli/releases/download/v${GH_VERSION}/$f"; \
    echo "${GH_SHA256}  /tmp/$f" | sha256sum -c -; \
    tar -xzf "/tmp/$f" -C /tmp; \
    install -m 0755 -o root -g root "/tmp/gh_${GH_VERSION}_linux_amd64/bin/gh" /usr/local/bin/gh; \
    rm -rf /tmp/gh_*; \
    gh --version
USER runner

LABEL org.opencontainers.image.source="https://github.com/yaimgod-labs/runner-image" \
      org.opencontainers.image.description="GitHub Actions runner for god-server: actions-runner plus gh"
