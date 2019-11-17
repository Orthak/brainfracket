#lang racket

;; Unsafe operations for S P E E D.
;; !! Use with Caution !!
(require racket/unsafe/ops)

(provide (all-defined-out))

;; Using a custom error structure that supports source
;; location for raised errors.
(define-struct (exn:fail:out-of-bounds exn:fail)
  (srcloc)
  #:property prop:exn:srclocs
    (lambda (a-struct)
      (list (exn:fail:out-of-bounds-srcloc a-struct))))

;; Create a new state, with a byte array of 30000 zeroes.
;; Initialize the pointer to 0.
(define-syntax-rule (new-state)
  (values (make-vector 30000 0)
              0))

;; Increment the pointer.
(define-syntax-rule (increment-pointer data pointer code-line)
  (begin
    (set! pointer (unsafe-fx+ pointer 1))
    (when (unsafe-fx>= pointer (unsafe-vector-length data))
      (raise (make-exn:fail:out-of-bounds
              "out of bounds"
              (current-continuation-marks)
              code-line)))))

;; Decrement the pointer.
(define-syntax-rule (decrement-pointer data pointer code-line)
  (begin
    (set! pointer (unsafe-fx- pointer 1))
    (when (unsafe-fx< pointer 0)
      (raise (make-exn:fail:out-of-bounds
              "out of bounds"
              (current-continuation-marks)
              code-line)))))

;; Increment the byte at the pointer.
;; Use the `modulo` function, to clamp the values of the
;; bytes between 0 and 256 inclusive.
(define-syntax-rule (increment-byte data pointer)
  (unsafe-vector-set! data pointer
                      (unsafe-fxmodulo
                       (unsafe-fx+
                        (unsafe-vector-ref data pointer) 1)
                       256)))

;; Decrement the byte at the pointer.
;; Use the `modulo` function, to clamp the values of the
;; bytes between 0 and 256 inclusive.
(define-syntax-rule (decrement-byte data pointer)
    (unsafe-vector-set! data pointer
                        (unsafe-fxmodulo
                         (unsafe-fx-
                          (unsafe-vector-ref data pointer) 1)
                         256)))
    
;; Print the byte at the pointer.
(define-syntax-rule (write-byte-out data pointer)
    (write-byte (unsafe-vector-ref data pointer)
                (current-output-port)))

;; Read the byte from the input stream, and set it at the current pointer.
;; If the value passed is an EOF object, set the value at the pointer to 0.
(define-syntax-rule (read-byte-in data pointer)
    (unsafe-vector-set! data pointer
                 (let ([a-value (read-byte
                                 (current-input-port))])
                   (if (eof-object? a-value)
                       0
                       a-value))))

;; Loop over the input for commands.
(define-syntax-rule (loop data pointer body ...)
  (let loop ()
    (unless (unsafe-fx= (unsafe-vector-ref data pointer)
               0)
      body ...
      (loop))))