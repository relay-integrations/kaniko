{{- /* Installing ni in these containers should be temporary (pending resolution of PN-59). */ -}}

{{- $PackageFileName := printf "ni-%s-linux-amd64.tar.xz" .SDKVersion -}}
{{- $PackageSHA256FileName := printf "%s.sha256" $PackageFileName -}}
{{- $PackageRepoURL := printf "https://packages.nebula.puppet.net/sdk/ni/%s" .SDKVersion -}}

FROM gcr.io/kaniko-project/executor:latest as base

FROM alpine:latest
ENV PATH "${PATH}:/kaniko"
ENV SSL_CERT_DIR=/kaniko/ssl/certs
ENV DOCKER_CONFIG /kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG /kaniko/.config/gcloud/docker_credential_gcr_config.json
RUN set -eux ; \
    mkdir -p /tmp/ni && \
    cd /tmp/ni && \
    wget {{ printf "%s/%s" $PackageRepoURL $PackageFileName }} && \
    wget {{ printf "%s/%s" $PackageRepoURL $PackageSHA256FileName }} && \
    echo "$( cat {{ $PackageSHA256FileName }} )  {{ $PackageFileName }}" | sha256sum -c - && \
    tar -xvJf {{ $PackageFileName }} && \
    mv ni-{{ .SDKVersion }}*-linux-amd64 /usr/local/bin/ni && \
    cd - && \
    rm -fr /tmp/ni
RUN apk --no-cache add bash ca-certificates curl git jq openssh socat && update-ca-certificates
COPY --from=base /kaniko /kaniko
RUN ["docker-credential-gcr", "config", "--token-source=env"]
COPY ./step.sh /nebula/step.sh
CMD ["/bin/bash", "/nebula/step.sh"]
