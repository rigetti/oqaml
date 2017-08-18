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