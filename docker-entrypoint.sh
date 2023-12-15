#!/bin/bash
set -e

if [ -z "$REEVE_API" ]; then
  echo This docker image is a Reeve CI pipeline step and is not intended to be used on its own.
  exit 1
fi

cd /reeve/src/${CONTEXT}

if [ -n "$RESULT_VAR" ]; then
  wget -O - -q "$REEVE_API/api/v1/var/set?key=$RESULT_VAR&value=failure" >/dev/null
fi

if [ -z "$NAME" ]; then
  echo Missing name
  exit 1
fi

if [ -n "$DOCKER_LOGIN_USER" ]; then
  if [ -z "$DOCKER_LOGIN_PASSWORD" ]; then
    echo Missing login password
    exit 1
  fi

  echo Login attempt for ${DOCKER_LOGIN_REGISTRY:-$NAME}...
  printf "%s\n" "$DOCKER_LOGIN_PASSWORD" | docker login -u "$DOCKER_LOGIN_USER" --password-stdin ${DOCKER_LOGIN_REGISTRY:-$NAME}
fi

FULL_NAME="$NAME:${TAG:-latest}"

if [ "$TEST" = "true" ] || [ "$TEST" = "fail" ]; then
  if ! [ "$TEST_PULL" = "true" ]; then
    echo Testing manifest for image $FULL_NAME...
    if DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect $FULL_NAME >/dev/null; then
      echo Image already exists - done
      if [ -n "$RESULT_VAR" ]; then
        wget -O - -q "$REEVE_API/api/v1/var/set?key=$RESULT_VAR&value=exists" >/dev/null
      fi
      ! [ "$TEST" = "fail" ]; exit
    fi
  else
    if [ "$PUSH" = "true" ]; then
      echo Removing local image $FULL_NAME to prepare testing...
      docker rmi $FULL_NAME >/dev/null 2>&1 ||:
    fi
    echo Pulling image $FULL_NAME for testing...
    if docker pull $FULL_NAME >/dev/null 2>&1; then
      echo Image already exists - done
      if [ -n "$RESULT_VAR" ]; then
        wget -O - -q "$REEVE_API/api/v1/var/set?key=$RESULT_VAR&value=exists" >/dev/null
      fi
      ! [ "$TEST" = "fail" ]; exit
    fi
  fi
  echo Image does not exist - continuing...
fi

declare -a ARGS
IFS=$'\n'
for arg in $(printf "%s" "$BUILD_ARGS" | xargs -n1); do
  ARGS+=("--build-arg" "$(eval printf \"%s\" \"$arg\")")
done
unset IFS

COMMAND="docker build $([[ -n "$NETWORK" ]] && printf "%s" "--network $NETWORK" ||:) $([[ "$USE_CACHE" = "false" ]] && printf "%s" "--no-cache" ||:) $([[ -n "$PLATFORM" ]] && printf "%s" "--platform $PLATFORM" ||:) $([[ "$PULL" = "always" ]] && printf "%s" "--pull" ||:) $([[ "$SQUASH" = "true" ]] && printf "%s" "--squash" ||:) -t $FULL_NAME"

echo Building image $FULL_NAME...
if [ "$FILE" = "-" ]; then
  $COMMAND "${ARGS[@]}" -
else
  $COMMAND "${ARGS[@]}" $([[ -n "$FILE" ]] && printf "%s" "-f $FILE" ||:) .
fi

if [ "$PUSH" = "true" ]; then
  echo Pushing image $FULL_NAME...
  docker push $FULL_NAME

  if [ -n "$TAG" ] && [ "$PUSH_LATEST" = "true" ]; then
    echo Tagging image $NAME:latest...
    docker tag $FULL_NAME $NAME:latest

    echo Pushing image $NAME:latest...
    docker push $NAME:latest
  fi
fi

if [ -n "$RESULT_VAR" ]; then
  wget -O - -q "$REEVE_API/api/v1/var/set?key=$RESULT_VAR&value=success" >/dev/null
fi
