#!/usr/bin/python3
# Copyright 2023 Google LLC
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

from babel.messages.jslexer import tokenize
import babel

from py_io_capture import decorate_module, dump_records, DUMP_FILE_NAME
import atexit
babel = decorate_module(babel)
atexit.register(dump_records, DUMP_FILE_NAME)

def TestOneInput(data):
  fdp = atheris.FuzzedDataProvider(data)
  try:
    l1 = list(tokenize(fdp.ConsumeUnicodeNoSurrogates(sys.maxsize)))
  except (
    babel.messages.pofile.PoFileError,
    babel.core.UnknownLocaleError,
    babel.messages.catalog.TranslationError,
    babel.numbers.UnknownCurrencyError,
    babel.plural.RuleError
  ):
    pass


def main():
  atheris.instrument_all()
  atheris.Setup(sys.argv, TestOneInput)
  atheris.Fuzz()


if __name__ == "__main__":
  main()
