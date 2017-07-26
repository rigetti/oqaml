oasis:
	oasis setup
	ocaml setup.ml -configure
all:
# https://stackoverflow.com/questions/16552834/how-to-use-thread-compiler-flag-with-ocamlbuild
	ocaml setup.ml -build -tag thread
