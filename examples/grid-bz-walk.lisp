#!/usr/bin/sbcl --script

(load "../src/load")
(load "../utils/grid")

(asdf:load-system "snek")


(defun mixed (x f)
  (declare (double-float x f))
  (+ (random (* f x)) (- x (* 2.0d0 (random x)))))


(defun rnd-dir ()
  (nth (rnd:rndi 4)
       (list (list 0 -1)
             (list 0 1)
             (list -1 0)
             (list 1 0))))

(defmacro -swap (n m n* m*)
  (with-gensyms (h w)
    `(progn (setf ,n ,n*)
            (setf ,m ,m*)
      (destructuring-bind (,h ,w) (rnd-dir)
        (setf ,n* (+ ,n ,h))
        (setf ,m* (+ ,m ,w))))))


(defun get-walker (grid)
  (let ((ngrid (length grid)))
    (let ((x 0.d0)
          (n (rnd:rndi ngrid))
          (m (rnd:rndi ngrid)))
      (destructuring-bind (n* m*)
        (math:add (list n m) (rnd-dir))

        (lambda (noise)
          (incf x (mixed noise 0.2d0))
          (when (> x 1.0d0) (-swap n m n* m*))
          (when (< x 0.0d0) (-swap n* m* n m))
          (setf x (mod x 1.0d0))
          (vec:on-line x
            (nth (mod m ngrid) (nth (mod n ngrid) grid))
            (nth (mod m* ngrid) (nth (mod n* ngrid) grid))))))))


(defun main (size fn)
  (let ((itt 1000000)
        (ngrid 7)
        (nwalkers 4)
        (noise 0.00001d0)
        (grains 10)
        (edge 60d0)
        (sand (sandpaint:make size
                :fg (pigment:white 0.05)
                :bg (pigment:dark))))


    (let* ((grid (get-grid (math:dfloat size) edge 5))
           (walkers-a (math:nrep nwalkers (get-walker grid)))
           (walkers-b (math:nrep nwalkers (get-walker grid))))

      (loop for i from 0 below itt do
        (print-every i 100000)
        (sandpaint:set-fg-color sand (pigment:hsv 0.51 1 1 0.05))
        (sandpaint:bzspl-stroke sand
          (bzspl:make (loop for w in walkers-a collect (funcall w noise))
                      :closed t)
          grains)

        (sandpaint:set-fg-color sand (pigment:hsv 0.91 1 1 0.05))
        (sandpaint:bzspl-stroke sand
          (bzspl:make (loop for w in walkers-b collect (funcall w noise))
                      :closed t)
          grains)))

    (sandpaint:save sand fn :gamma 1.5)))

(time (main 2000 (second (cmd-args))))

