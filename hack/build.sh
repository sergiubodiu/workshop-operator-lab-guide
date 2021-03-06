#! /usr/bin/env bash
# Helper script to build container images for each workshop

WORKSHOP_NAME=$1
LOCATION=${2:local}
QUAY_PROJECT=${3:-creynold}

cd $(dirname $(realpath $0))/..
if [ -f .quay_creds ]; then
  LOCATION=quay
  . .quay_creds
fi

case $LOCATION in
  local)
    podman build --build-arg workshop_name=$WORKSHOP_NAME \
      -t quay.io/$QUAY_PROJECT/operator-workshop-lab-guide-$WORKSHOP_NAME .
  ;;
  quay)
    echo Logging in to quay.io
    # designed to be used by travis-ci, where the docker_* variables are defined
    echo "$DOCKER_PASSWORD" | podman login -u "$DOCKER_USERNAME" --password-stdin quay.io || exit 1

    echo Building image
    podman build --build-arg workshop_name=$WORKSHOP_NAME \
      -t quay.io/$QUAY_PROJECT/operator-workshop-lab-guide-$WORKSHOP_NAME . || exit 2
    echo Pushing image
    podman push quay.io/$QUAY_PROJECT/operator-workshop-lab-guide-$WORKSHOP_NAME || exit 3
  ;;
  *)
    echo "usage: ./hack/build.sh WORKSHOP_NAME [local|quay] [QUAY_PROJECT]"
  ;;
esac
