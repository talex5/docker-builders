# Create Docker container user to build 0install generic binaries.
# We use a very old Ubuntu to maximise compatibility.

# Or 32-bit:
FROM talex5/lucid32:orig
ENTRYPOINT ["linux32"]
ADD sources.list /etc/apt/sources.list
ENV CPU i686

RUN apt-get update
RUN apt-get install -y vim zeroinstall-injector libgtk2.0-dev libcurl4-openssl-dev build-essential --no-install-recommends
RUN apt-get install -y curl
RUN useradd -m -u 1000 build

ENV HOME /root
# Bootstrap a modern 0install from 10.04's ancient copy, via an intermediate version :-)
ADD trustdb.xml /root/.config/0install.net/injector/trustdb.xml
RUN 0launch http://0install.net/2007/interfaces/ZeroInstall.xml --main=/install.sh --cpu "$CPU" http://0install.net/tools/0install.xml local
RUN apt-get remove -y zeroinstall-injector
RUN apt-get install -y m4 unzip

# Install opam, OCaml and 0install's dependencies
USER build
ENV HOME /home/build
RUN mkdir /home/build/bin
ENV PATH /home/build/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
RUN 0install add opam --cpu "$CPU" http://tools.ocaml.org/opam.xml
RUN linux32 opam init --comp=4.01.0
RUN linux32 opam install yojson xmlm ounit react lwt extlib ocurl obus lablgtk sha
RUN 0install add 0release --cpu "$CPU" http://0install.net/2007/interfaces/0release.xml

WORKDIR /mnt
