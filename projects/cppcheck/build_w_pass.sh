#!/bin/bash -eu
# Copyright 2019 Google Inc.
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
export REPORT_FLAGS="-Xclang -load -Xclang ./ReportFunctionExecutedPass/libReportPass.so -flegacy-pass-manager"
export CFLAGS="$CFLAGS ./ReportFunctionExecutedPass/reporter.stdc++.o $REPORT_FLAGS"
export CXXFLAGS="$CXXFLAGS ./ReportFunctionExecutedPass/reporter.stdc++.o $REPORT_FLAGS"

# build fuzzer

cd $SRC/cppcheck/oss-fuzz
make oss-fuzz-client
cp oss-fuzz-client $OUT/


# ! mv Pass to out since using relative path
mv $REPORT_PASS $OUT