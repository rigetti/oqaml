oasis:
	oasis setup
	ocaml setup.ml -configure
all:
	ocaml setup.ml -build
