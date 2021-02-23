#!/bin/bash
set -euo pipefail

CREDENTIALS=$(ni get -p {.credentials})
if [ -n "${CREDENTIALS}" ]; then
  ni credentials config
  export GOOGLE_APPLICATION_CREDENTIALS=/workspace/credentials.json
fi

GOOGLE=$(ni get -p {.google})
if [ -n "${GOOGLE}" ]; then
  ni gcp config -d "/workspace/.gcp"
  export GOOGLE_APPLICATION_CREDENTIALS=/workspace/.gcp/credentials.json
fi

DOCKERHUB=$(ni get -p {.dockerhub})
if [[ -n $DOCKERHUB ]]; then
  mkdir -p /kaniko/.docker
  cat << EOF > /kaniko/.docker/config.json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "$DOCKERHUB"
    }
  }
}
EOF
fi

ni git clone

NAME=$(ni get -p {.git.name})
CONTEXT=$(ni get -p {.context})
DOCKERFILE=$(ni get -p {.dockerfile})
DESTINATION=$(ni get -p {.destination})

declare -a BUILD_ARGS_OPTIONS="($(ni get | jq -r 'try .buildArgs | to_entries[] | @sh "--build-arg=\( .key )=\( .value )"'))"

CONTEXT="/workspace/${NAME}/${CONTEXT}"
DOCKERFILE="${CONTEXT}/${DOCKERFILE:-Dockerfile}"

/kaniko/executor \
    ${BUILD_ARGS_OPTIONS[@]} \
    --dockerfile=${DOCKERFILE} \
    --context=${CONTEXT} \
    --destination=${DESTINATION} \
    --force
