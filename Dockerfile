FROM ubuntu:bionic

ARG QUICKLISP_VERSION=2019-07-11
ARG QUICKLISP_URL=http://beta.quicklisp.org/dist/quicklisp/${QUICKLISP_VERSION}/distinfo.txt

RUN apt-get update -y && \
    apt-get install -y \
    gcc \
    curl \
    libpng-dev \
    sbcl \
    cl-quicklisp

RUN curl -o /tmp/quicklisp.lisp 'https://beta.quicklisp.org/quicklisp.lisp' && \
    sbcl --noinform --non-interactive --load /tmp/quicklisp.lisp --eval \
        "(quicklisp-quickstart:install :dist-url \"${QUICKLISP_URL}\")" && \
    sbcl --noinform --non-interactive --load ~/quicklisp/setup.lisp --eval \
        '(ql-util:without-prompting (ql:add-to-init-file))' && \
    echo '#+quicklisp(push "/src" ql:*local-project-directories*)' >> ~/.sbclrc && \
    rm -f /tmp/quicklisp.lisp

ADD ./quicklisp-libraries.txt /static/quicklisp-libraries.txt
RUN sbcl --eval '(ql:quickload (uiop:read-file-lines "/static/quicklisp-libraries.txt"))' --quit

WORKDIR /work


