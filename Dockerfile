FROM docker

RUN apk add bash
COPY --chmod=500 docker-entrypoint.sh /usr/local/bin/

# DOCKER_LOGIN_REGISTRY: docker registry to log in to - can be inferred from the image name if left empty
ENV DOCKER_LOGIN_REGISTRY=
# DOCKER_LOGIN_USER: user for logging into docker registry
ENV DOCKER_LOGIN_USER=
# DOCKER_LOGIN_PASSWORD: password for logging into docker registry
ENV DOCKER_LOGIN_PASSWORD=
# NAME: image name (required)
ENV NAME=
# TAG: image tag
ENV TAG=
# FILE: Dockerfile name (use - for STDIN)
ENV FILE=
# CONTEXT: Context directory (relative to project root)
ENV CONTEXT=.
# BUILD_ARGS: Space separated list of ARG=VALUE pairs - can contain other params as variables
ENV BUILD_ARGS=
# NETWORK: Networking mode for RUN instructions during build
ENV NETWORK=default
# USE_CACHE=true|false
ENV USE_CACHE=true
# PLATFORM: Platform to be used if server is multi-platform capable
ENV PLATFORM=
# PULL=always|missing
ENV PULL=missing
# SQUASH=true|false
ENV SQUASH=false
# PUSH=true|false
ENV PUSH=true
# PUSH_LATEST=true|false
ENV PUSH_LATEST=true
# TEST=true|fail|false
ENV TEST=true
# TEST_PULL=true|false
ENV TEST_PULL=false
# RESULT_VAR: Name of a runtime variable for setting the step result (failure|exists|success) to
ENV RESULT_VAR=

ENTRYPOINT ["docker-entrypoint.sh"]
