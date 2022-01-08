ARG NS3_VERSION=3.32
ARG BUILD_PROFILE=debug

FROM marshallasch/ns3:${NS3_VERSION}-${BUILD_PROFILE}

LABEL org.opencontainers.version="v1.0.0"
LABEL org.opencontainers.image.authors="Marshall Asch <masch@uoguelph.ca> (https://marshallasch.ca)"
LABEL org.opencontainers.image.url="https://github.com/MarshallAsch/ns3-action.git"
LABEL org.opencontainers.image.source="https://github.com/MarshallAsch/ns3-action.git"
LABEL org.opencontainers.image.vendor="Marshall Asch"
LABEL org.opencontainers.image.licenses="ISC"
LABEL org.opencontainers.image.title="ns-3 github action docker container"
LABEL org.opencontainers.image.description="ns-3 docker container for github action pipelines"


ENV NS3_VERSION=$NS3_VERSION
ENV BUILD_PROFILE=$BUILD_PROFILE

VOLUME ["/contrib"]

ENTRYPOINT ["/ns3/entrypoint.sh"]
COPY entrypoint.sh /ns3/entrypoint.sh

# these two labels will change every time the container is built
# put them at the end because of layer caching
ARG VCS_REF
LABEL org.opencontainers.image.revision="${VCS_REF}"

ARG BUILD_DATE
LABEL org.opencontainers.image.created="${BUILD_DATE}"
