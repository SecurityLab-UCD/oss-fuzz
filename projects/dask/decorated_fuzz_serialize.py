#!/usr/bin/python3
# Copyright 2022 Google LLC
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

import sys
import atheris
import json
from dask.config import (
    deserialize,
    serialize
)

from py_io_capture import decorate_module, dump_records, DUMP_FILE_NAME
import atexit
dask.config = decorate_module(dask.config)
atexit.register(dump_records, DUMP_FILE_NAME)

@atheris.instrument_func
def TestOneInput(data):
  fdp = atheris.FuzzedDataProvider(data)
  try:
    fuzzed_dict = json.loads(fdp.ConsumeString(sys.maxsize))
  except json.JSONDecodeError:
    return

  if type(fuzzed_dict) is not dict:
    return
  serialized = serialize(fuzzed_dict)
  config = deserialize(serialized)

def main():
  atheris.instrument_all()
  atheris.Setup(sys.argv, TestOneInput, enable_python_coverage=True)
  atheris.Fuzz()


if __name__ == "__main__":
  main()
