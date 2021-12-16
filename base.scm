(module o4.base
  *
(import scheme
        (chicken base)
        (chicken io)
        (chicken pathname)
        (chicken process-context))

;;; [stx]

(define-syntax if-let
  (syntax-rules ()
    ((if-let ((var value) ...)
       consequent ...)
     (let ((var value) ...)
       (if (and var ...)
           consequent ...)))))

(define-syntax when-let
  (syntax-rules ()
    ((when-let (binding)
       body ...)
     (if-let (binding)
       (begin body ...)))))

;;; [ctx]

(define (getenv var)
  (if-let ((v (get-environment-variable var)))
    v
    (error 'getenv "environment does not contain variable" var)))

;;; [io]

(define prn print)

(define (read-file path)
  (call-with-input-file path
    (lambda (port)
      (read port))))

(define (append-file path data)
  (call-with-output-file path
    (lambda (port)
      (write data port))
    #:append))

(define (slurp path)
  (call-with-input-file path
    (lambda (port)
      (read-string #f port))))

(define (basename path)
  (pathname-strip-directory path)))
