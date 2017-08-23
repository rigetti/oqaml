FROM ryanrhymes/owl

RUN opam install -y core_extended

ENV OQAMLPATH /root/oqaml

RUN cd /root && git clone https://github.com/rigetticomputing/oqaml.git

RUN make -C $OQAMLPATH oasis-test
RUN make -C $OQAMLPATH oasis
RUN make -C $OQAMLPATH install

WORKDIR $OQAMLPATH
ENTRYPOINT /bin/bash
