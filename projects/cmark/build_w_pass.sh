#!/bin/bash -eu
# Copyright 2017 Google Inc.
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

# ! add Pass before building the fazzers

mkdir -p $OUT/lib
cp $REPORT_PASS/libreporter.so $OUT/lib

REPORT_FLAGS="-Xclang -load -Xclang $REPORT_PASS/libReportPass.so -flegacy-pass-manager"
REPORTER_FLAGS="$OUT/lib/libreporter.so"
export CFLAGS="${CFLAGS:=} $REPORT_FLAGS $REPORTER_FLAGS"
export CXXFLAGS="${CXXFLAGS:=} $REPORT_FLAGS $REPORTER_FLAGS"

make -j$(nproc) cmake_build

$CC $CFLAGS -Isrc -Ibuild/src -c test/cmark-fuzz.c -o cmark_fuzzer.o
$CXX $CXXFLAGS $LIB_FUZZING_ENGINE cmark_fuzzer.o build/src/libcmark.a -o $OUT/cmark_fuzzer

cp $SRC/*.options $OUT/
cp test/fuzzing_dictionary $OUT/cmark.dict

mkdir -p corpus
python3 test/spec_tests.py --fuzz-corpus corpus --spec test/spec.txt
python3 test/spec_tests.py --fuzz-corpus corpus --spec test/regression.txt
python3 test/spec_tests.py --fuzz-corpus corpus --spec test/smart_punct.txt
zip -j $OUT/cmark_fuzzer_seed_corpus.zip corpus/*

# # ! mv Pass to out since using relative path
mv $REPORT_PASS $OUT