FROM debian:stable

WORKDIR /usr/local/src

ADD . /usr/local/src

RUN apt-get update && apt-get install -y --no-install-recommends git-core subversion make cmake clang python ca-certificates wget

CMD ["/usr/local/src/build-stdlib.sh"]
