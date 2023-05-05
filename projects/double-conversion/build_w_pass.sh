#!/bin/bash -eu
#
# Copyright 2019 Google LLC
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

mkdir -p ${WORK}/double-conversion
cd ${WORK}/double-conversion

cmake -GNinja ${SRC}/double-conversion/
ninja

# ! add Pass before building the fazzers
REPORT_FLAGS="-Xclang -load -Xclang $REPORT_PASS/libReportPass.so -flegacy-pass-manager"
REPORTER_FLAGS="$REPORT_PASS/reporter.c++.o -lc++ -pthread -lm"
export CFLAGS="${CFLAGS:=} $REPORT_FLAGS $REPORTER_FLAGS"
export CXXFLAGS="${CXXFLAGS:=} $REPORT_FLAGS $REPORTER_FLAGS"

fuzzer="string_to_double_fuzzer"

${CXX} ${CXXFLAGS} -std=c++11 -I${SRC}/double-conversion/double-conversion \
    -c ${SRC}/${fuzzer}.cc \
    -o ${fuzzer}.o
${CXX} ${CXXFLAGS} -std=c++11 ${fuzzer}.o \
    -o ${OUT}/${fuzzer} "${LIB_FUZZING_ENGINE}" libdouble-conversion.a

# ! mv Pass to out since using relative path
mv $REPORT_PASS $OUT