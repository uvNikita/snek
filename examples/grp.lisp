#!/usr/bin/sbcl --script

(load "../src/load.lisp")

(asdf:load-system "snek")


(defun init (snk rep rad)
  (loop for x in (math:linspace rep 200d0 800d0) for i from 0 do
    (loop for y in (math:linspace rep 200d0 800d0) for j from 0 do
      (let ((g (snek:add-grp! snk :type 'path)))
        (snek:add-polygon! snk (rnd:rndi 3 6) rad
                           :xy (vec:vec x y)
                           :g g)))))

(defun main (size fn)
  (let* ((scale (/ size 1000))
        (border (* scale 200d0))
        (grains (* scale scale 4))
        (itt 10000)
        (noise (* scale 0.000000018d0))
        (rep 10)
        (rad (* scale 25d0))
        (snk (snek:make :max-verts 10000))
        (sand (sandpaint:make size
                              :fg (pigment:white 0.005)
                              :bg (pigment:gray 0.1d0))))

    (loop for x in (math:linspace rep border (- size border)) for i from 0 do
      (loop for y in (math:linspace rep border (- size border)) for j from 0 do
        (let ((g (snek:add-grp! snk :type 'path)))
          (snek:add-polygon! snk (rnd:rndi 3 6) rad
                             :xy (vec:vec x y)
                             :g g))))

    (let ((grp-states (make-hash-table :test #'equal)))
      (snek:itr-grps (snk g)
        (setf (gethash g grp-states) (rnd:get-acc-circ-stp*)))

      (loop for i from 0 to itt do
        (print-every i 1000)

        (snek:with (snk)
          (snek:itr-grps (snk g)
            (let ((ns (funcall (gethash g grp-states) noise)))
              (snek:itr-grp-verts (snk v :g g)
                (snek:move-vert? v
                  (vec:add ns (rnd:in-circ 0.05d0)))))))

        (snek:itr-grps (snk g :collect nil)
          (snek:draw-edges snk sand grains :g g))))

    ;(sandpaint:chromatic-aberration sand)
    (sandpaint:pixel-hack sand)
    (sandpaint:save sand fn)))


(time (main (parse-integer (third (cmd-args))) (second (cmd-args))))

