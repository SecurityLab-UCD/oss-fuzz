#!/bin/bash -eu
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
mkdir json-c-build
cd json-c-build

echo "Building json-c with PASS"

REPORT_FLAGS="-Xclang -load -Xclang $REPORT_PASS/libReportPass.so -flegacy-pass-manager"
REPORTER_FLAGS="$REPORT_PASS/reporter.c++.o -lc++ -pthread -lm -Wno-unused-command-line-argument"
# https://unix.stackexchange.com/questions/594841/how-do-i-assign-a-value-to-a-bash-variable-if-that-variable-is-null-unassigned-f/594845
# Use ${X:=} to prevent the case where this variable doesn't exist.
export CFLAGS="${CFLAGS:=} $REPORT_FLAGS $REPORTER_FLAGS"
export CXXFLAGS="${CXXFLAGS:=} $REPORT_FLAGS $REPORTER_FLAGS"
cmake -DBUILD_SHARED_LIBS=OFF ..
make -j$(nproc)
cd ..

cp $SRC/*.dict $OUT/

for f in $SRC/*_fuzzer.cc; do
    fuzzer=$(basename "$f" _fuzzer.cc)
    $CXX $CXXFLAGS -std=c++11 -I$SRC/json-c -I$SRC/json-c/json-c-build\
         $SRC/${fuzzer}_fuzzer.cc -o $OUT/${fuzzer}_fuzzer \
         $LIB_FUZZING_ENGINE $SRC/json-c/json-c-build/libjson-c.a
done
