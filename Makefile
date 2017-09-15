# Copyright 2017 Rigetti Computing, Inc.
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

.PHONY: readmes all test docs clean
test:
	jbuilder runtest -j1 --no-buffer
all:
	jbuilder build @install
install:
	jbuilder install
uninstall:
	jbuilder uninstall
docs:
	jbuilder build @doc
clean:
	jbuilder clean
cleanall:
	jbuilder uninstall && jbuilder clean
	rm -rf `find . -name .merlin`
readmes:
	python -m readme2tex --project OQaml --username oqaml --output walkthrough.md readmes/walkthrough2tex.md --nocdn --pngtrick
	rm -r readmes/svgs
	mv svgs readmes/
	mv walkthrough.md readmes/
