#!/bin/bash
set -euo pipefail

export GOOGLE_APPLICATION_CREDENTIALS=/workspace/credentials.json

ni git clone
ni credentials config

NAME=$(ni get -p {.git.name})
CONTEXT=$(ni get -p {.context})
DOCKERFILE=$(ni get -p {.dockerfile})
DESTINATION=$(ni get -p {.destination})

declare -a BUILD_ARGS_OPTIONS="($(ni get | jq -r 'try .buildArgs | to_entries[] | @sh "--build-arg=\( .key )=\( .value )"'))"

CONTEXT="/workspace/${NAME}/${CONTEXT}"
DOCKERFILE="${CONTEXT}/${DOCKERFILE:-Dockerfile}"

# kaniko uses the DMI/SMBIOS information (indirectly via sysfs) to determine
# whether we're running on GCE. Since cloud execution indeed happens on GCE, our
# CRI (correctly?) propagates the GCE DMI information into the container.
#
# However, we firewall off access to the GCE metadata API. kaniko will then sit
# in an infinite loop waiting for the metadata API to come up. Of course, our
# uncompromising firewall will never let it succeed.
#
# Since we don't have a good way to inject our own DMI information yet, we
# instead stub out a fake HTTP server that makes kaniko think the metadata
# service is up.
case "$( </sys/class/dmi/id/product_name )" in
*Google*)
  ni log warn 'Detected Google DMI configuration, installing workaround...'

  socat tcp-listen:80,bind=127.0.0.111,crlf,reuseaddr,fork system:'echo "HTTP/1.1 200 OK"; echo "Connection: close"; echo;' &
  cat >>/etc/hosts <<<$'\n127.0.0.111 metadata.google.internal\n'
  ;;
esac

/kaniko/executor \
    ${BUILD_ARGS_OPTIONS[@]} \
    --dockerfile=${DOCKERFILE} \
    --context=${CONTEXT} \
    --destination=${DESTINATION}
