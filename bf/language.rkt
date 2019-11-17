#lang racket

(require "semantics.rkt"
         racket/stxparam)

(provide greater-than
         less-than
         plus
         minus
         period
         comma
         brackets
         (rename-out [my-module-begin #%module-begin]))

;; current-data and current-pointer are used by
;; the rest of the language.
(define-syntax-parameter current-data #f)
(define-syntax-parameter current-pointer #f)

;; Every module will have it's own state.
(define-syntax-rule (my-module-begin body ...)
  (#%plain-module-begin
   (let-values ([(fresh-data fresh-pointer) (new-state)])
     (syntax-parameterize
         ([current-data
           (make-rename-transformer #'fresh-data)]
          [current-pointer
           (make-rename-transformer #'fresh-pointer)])
       body ...))))

(define-syntax (greater-than stx)
  (syntax-case stx ()
    [(_)
     (quasisyntax/loc stx
       (increment-pointer current-data current-pointer
                          (srcloc '#,(syntax-source stx)
                                  '#,(syntax-line stx)
                                  '#,(syntax-column stx)
                                  '#,(syntax-position stx)
                                  '#,(syntax-span stx))))]))

(define-syntax (less-than stx)
  (syntax-case stx ()
    [(_)
     (quasisyntax/loc stx
       (decrement-pointer current-data current-pointer
                          (srcloc '#,(syntax-source stx)
                                  '#,(syntax-line stx)
                                  '#,(syntax-column stx)
                                  '#,(syntax-position stx)
                                  '#,(syntax-span stx))))]))

(define-syntax-rule (plus)
  (increment-byte current-data current-pointer))

(define-syntax-rule (minus)
  (decrement-byte current-data current-pointer))

(define-syntax-rule (period)
  (write-byte-out current-data current-pointer))

(define-syntax-rule (comma)
  (read-byte-in current-data current-pointer))

(define-syntax-rule (brackets body ...)
  (loop current-data current-pointer body ...))
