#lang racket

;; The only export of the module.
(provide parse-expression)

;; parse-expression: any input-port -> (U syntax eof)
;; Producies either a syntax object, or an EOF.
(define (parse-expression src in)
  (define-values (line column position) (port-next-location in))
  (define next-char (read-char in))

  ;; decorate: s-expression number number -> syntax
  ;; Wrap the s-expr with source location.
  (define (decorate sexp span)
    (datum->syntax #f sexp (list src line column position span)))

  (cond
    [(eof-object? next-char) eof]
    [else
     (case next-char
       [(#\<) (decorate '(less-than) 1)]
       [(#\>) (decorate '(greater-than) 1)]
       [(#\+) (decorate '(plus) 1)]
       [(#\-) (decorate '(minus) 1)]
       [(#\,) (decorate '(comma) 1)]
       [(#\.) (decorate '(period) 1)]
       [(#\[)
        ;; More complex case. Keep reading a list
        ;; of expressions, and then construct a wrapping
        ;; bracket around the entire chain.
        (define elements (parse-expressions src in))
        (define-values (l c tail-position)
          (port-next-location in))
        (decorate `(brackets ,@elements)
                  (- tail-position position))]
       [else
        (parse-expression src in)])]))

;; parse-expressions: input-port -> (listof syntax)
;; Parse a list of expressions.
(define (parse-expressions source-name in)
  (define peeked-char (peek-char in))
  (cond
    [(eof-object? peeked-char)
     (error 'parse-expressions "Expected ], but got end of file.")]
    [(char=? peeked-char #\])
     (read-char in)
     empty]
    [(member peeked-char (list #\< #\> #\+ #\- #\, #\. #\[))
     (cons (parse-expression source-name in)
           (parse-expressions source-name in))]
    [else
     (read-char in)
     (parse-expressions source-name in)]))

