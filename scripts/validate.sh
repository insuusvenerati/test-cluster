#!/usr/bin/env bash

set -o errexit

echo "INFO - Downloading Flux OpenAPI schemas"
mkdir -p /tmp/flux-crd-schemas/master-standalone-strict
curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz | tar zxf - -C /tmp/flux-crd-schemas/master-standalone-strict

find . -type f -name '*.yaml' -print0 | while IFS= read -r -d $'\0' file; do
  echo "INFO - Validating $file"
  yq e 'true' "$file" >/dev/null
done

echo "INFO - Validating clusters"
find ./clusters -type f \( -name '*.yaml' ! -name 'kustomization.yaml' \) -print0 | while IFS= read -r -d $'\0' file; do
  kubeval "${file}" --strict --ignore-missing-schemas --quiet --additional-schema-locations=file:///tmp/flux-crd-schemas
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    exit 1
  fi
done

echo "INFO - Validating kustomize overlays"
find . -type f -name $kustomize_config -print0 | while IFS= read -r -d $'\0' file; do
  echo "INFO - Validating kustomization ${file/%$kustomize_config/}"
  kustomize build "${file/%$kustomize_config/}" $kustomize_flags | kubeval --strict --ignore-missing-schemas --quiet --additional-schema-locations=file:///tmp/flux-crd-schemas
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    exit 1
  fi
done
