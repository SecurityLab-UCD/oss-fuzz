# !/bin/bash -eu
# Copyright 2020 Google Inc.
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
export REPORT_FLAGS="-Xclang -load -Xclang /src/astc-encoder/ReportFunctionExecutedPass/libReportPass.so -flegacy-pass-manager"
export CFLAGS="$CFLAGS /src/astc-encoder/ReportFunctionExecutedPass/libreporter.so $REPORT_FLAGS"
export CXXFLAGS="$CXXFLAGS /src/astc-encoder/ReportFunctionExecutedPass/libreporter.so $REPORT_FLAGS"

# build project and project-hosted fuzzers
$SRC/astc-encoder/Source/Fuzzers/build.sh

# ! mv Pass to out since using relative path
mv $REPORT_PASS $OUT