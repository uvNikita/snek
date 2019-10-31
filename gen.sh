#!/usr/bin/env bash
docker run -it -v $(pwd):/work -w /work/examples snek /usr/bin/sbcl --dynamic-space-size 8192 --script "$1" "../out/$2" "$3"
