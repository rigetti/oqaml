# Setting up your OCaml environment

This guide is intended to give you a general idea of how to get started with OCaml. An easy way to handle OCaml packages is [Opam](https://opam.ocaml.org/doc/Install.html). Installation on MacOS and Linux distributions has many steps but is straight forward. If you have a working OCaml Environment you can skip to the OQaml setup section.

## Setting up the OCaml environment

1. Install OCaml package manager:

    + **Ubuntu**
    ```bash
    apt-get install opam
    ```

    + **MacOS**
    ```bash
    brew install opam
    ```

2. Initialize the package manager

    ```bash
    opam init
    ```

3. To interact with OQaml you will need to set up OCaml version 4.04.2. You can do this with opam as follows

    ```bash
    opam switch 4.04.2
    ```

4. Repeat steps 3 to ensure your environment is set up with the right version dependencies (Don't forget to check your `.bashrc`)

    ```bash
    opam config env
    ```
There will be several ENV variables displayed. Make sure to put them into your `.bashrc` and source it. You are now all set up in the right OCaml environment. To get install OQaml we need to install some more dependencies and OCaml packages.

5. Setting up [oasis](http://oasis.forge.ocamlcore.org/);an OCaml build system manager:

    ```bash
    opam install oasis
    ```

    Depending on your distribution of Linux od MacOS there might be OS dependencies missing. Opam is giving you good guidelines to check for those dependencies and help you install missing ones. E.g. for a missing `conf-m4.1` dependency opam suggests to run

    ```bash
    opam depext conf-m4.1
    ```
    which searches and helps installing missing the OS libraries.

6. Install [utop](https://github.com/diml/utop) to install a powerful OCaml REPL

    ```bash
    opam install utop
    ```

## Installing OQaml

1. Installing [Core_extended](https://github.com/janestreet/core_extended)

    ```bash
    opam install core_extended
    ```

2. The current version of OQaml depends on the development version of [Owl](https://github.com/ryanrhymes/owl), which needs to be installed by hand. More detailed install instructions are found in its [README](https://github.com/ryanrhymes/owl/blob/master/README.md), but here is a short list:

    1. `git clone git@github.com:ryanrhymes/owl.git`
    2. `cd owl`
    2. ensure `openblas` and `lapacke` are installed on your OS.
    3. `opam install ctypes dolog eigen gsl oasis plplot atdgen`. In this process there might be more OS dependencies you have to install. Simply let opam help you to figure out which OS libraries are missing with a couple of `opam depext <X>`.
    4. `make oasis`
    5. `make && make install`


3. You are now ready to install OQaml. To this end move into the OQaml directory and run

    ```bash
    make oasis && make install
    ```
