#lang racket
(require "parenthec.rkt")

#|introduce the union for continuations|#
#|for an interpreter, you also need the unions for closures,
  environments, and expressions|#

(define-union continuation
  (fib-sub2 fib-sub1 k)
  (fib-sub1 n k)
  (init-k jump-out))

(define-registers fib-cps-n apply-k-v cc)
(define-program-counter pc)

(define-label apply-k
  (union-case cc continuation
    [(fib-sub2 fib-sub1 k)
     (begin [set! cc k]
            [set! apply-k-v (+ fib-sub1 apply-k-v)]
            (set! pc apply-k))]
    [(fib-sub1 n k)
     (begin [set! cc (continuation_fib-sub2 apply-k-v k)]
            [set! fib-cps-n (sub1 (sub1 n))]
            (set! pc fib-cps))]
    [(init-k jump-out) (dismount-trampoline jump-out)]))

(define-label fib-cps
  (cond
    [(<= fib-cps-n 1)
     (begin [set! cc cc]
            [set! apply-k-v 1]
            (set! pc apply-k))]
    [else
     (begin [set! cc (continuation_fib-sub1 fib-cps-n cc)]
            [set! fib-cps-n (sub1 fib-cps-n)]
            (set! pc fib-cps))]))

#|always mount trampoline after everything|#
(define-label main
  (begin [set! fib-cps-n 5]
         (set! pc fib-cps)
         (mount-trampoline continuation_init-k cc pc)
         (printf "~s" apply-k-v)))
(main)
