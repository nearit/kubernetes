#!/bin/bash

# Copyright 2015 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE}")/..
source "${KUBE_ROOT}/hack/lib/init.sh"

kube::golang::setup_env

generated_files=($(
  find . -not \( \
      \( \
        -wholename './output' \
        -o -wholename './_output' \
        -o -wholename './release' \
        -o -wholename './target' \
        -o -wholename '*/third_party/*' \
        -o -wholename '*/Godeps/*' \
      \) -prune \
    \) -name '*.generated.go'))

for generated_file in ${generated_files[@]}; do
  cat "${generated_file}" > "${generated_file}.original"
done

${KUBE_ROOT}/hack/update-codecgen.sh

ret=0
# Generate files in the dependency order.
for generated_file in ${generated_files[@]}; do
  cur=0
  diff -Naupr -I 'Auto generated by' "${generated_file}" "${generated_file}.original" || cur=$?
  if [[ $cur -eq 0 ]]; then
    echo "${generated_file} up to date."
  else
    echo "${generated_file} was out of date. Please run hack/update-codecgen.sh. (If you're running locally, this was run for you already.)"
    ret=1
  fi

  rm -f "${generated_file}.original"
done

exit $ret