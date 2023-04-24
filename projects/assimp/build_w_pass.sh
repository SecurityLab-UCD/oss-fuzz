#!/bin/bash -eu
# Copyright 2021 Google LLC
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


# generate build env and build assimp
cmake CMakeLists.txt -G "Ninja" -DBUILD_SHARED_LIBS=OFF -DASSIMP_BUILD_ZLIB=ON \
                                -DASSIMP_BUILD_TESTS=OFF -DASSIMP_BUILD_ASSIMP_TOOLS=OFF \
                                -DASSIMP_BUILD_SAMPLES=OFF
                                 
# ! add Pass before building the fazzers
export REPORT_FLAGS="-Xclang -load -Xclang /src/assimp/ReportFunctionExecutedPass/libreporter.so -flegacy-pass-manager"
export CFLAGS="$CFLAGS /src/assimp/ReportFunctionExecutedPass/libreporter.so $REPORT_FLAGS"
export CXXFLAGS="$CXXFLAGS /src/assimp/ReportFunctionExecutedPass/libreporter.so $REPORT_FLAGS"

cmake --build .

# Build the fuzzer
$CXX $CXXFLAGS $LIB_FUZZING_ENGINE -std=c++11 -I$SRC/assimp/include \
		fuzz/assimp_fuzzer.cc -o $OUT/assimp_fuzzer  \
		./lib/libassimp.a ./contrib/zlib/libzlibstatic.a

# ! mv Pass to out since using relative path
mv $REPORT_PASS $OUT