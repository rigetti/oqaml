# Copyright 2017 Rigetti Computing, Inc.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

oasis:
	oasis setup
	ocaml setup.ml -configure
oasis-test:
	oasis setup
	ocaml setup.ml -configure --enable-tests
	ocaml setup.ml -build -tag thread
	ocaml setup.ml -test
all:
# https://stackoverflow.com/questions/16552834/how-to-use-thread-compiler-flag-with-ocamlbuild
	ocaml setup.ml -build -tag thread
install:
	ocaml setup.ml -build -tag thread
	ocaml setup.ml -uninstall
	ocaml setup.ml -install
uninstall:
	ocamlfind remove oqaml
docs:
	ocaml setup.ml -doc
.PHONY: readmes
readmes:
	python -m readme2tex --project OQaml --username oqaml --output walkthrough.md readmes/walkthrough2tex.md --nocdn
	rm -r readmes/svgs
	mv svgs readmes/
	mv walkthrough.md readmes/