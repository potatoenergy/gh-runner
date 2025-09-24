ARG BASE=debian:bookworm-slim
FROM ${BASE}

ARG RUNNER_VERSION=2.328.0

ARG TARGETARCH
RUN set -eux; \
  case "${TARGETARCH}" in \
  "arm64") RUNNER_ARCH=linux-arm64 ;; \
  "amd64") RUNNER_ARCH=linux-x64 ;; \
  "arm") RUNNER_ARCH=linux-arm ;; \
  *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
  esac; \
  echo "RUNNER_ARCH=${RUNNER_ARCH}" >> /etc/environment

ENV RUNNER_HOME=/home/runner/actions-runner \
  DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates curl tar gzip jq git libicu-dev libssl-dev \
  libkrb5-3 libcurl4 libunwind8 libstdc++6 \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash runner \
  && mkdir -p ${RUNNER_HOME} \
  && chown -R runner:runner ${RUNNER_HOME}

WORKDIR ${RUNNER_HOME}

RUN set -eux; \
  . /etc/environment; \
  curl -fsSL "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" \
  | tar -xz && rm -f *.tar.gz

COPY --chown=runner:runner entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

USER runner
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD [ -f /tmp/runner_health ]

ENTRYPOINT ["/entrypoint.sh"]