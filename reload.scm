(define rl)

(let ()
  
(define-record-type <file>
  (make-file path mtime counter)
  file?
  (path path)
  (mtime mtime (setter mtime))
  (counter counter (setter counter)))

(define (fs-mtime file)
  (file-modification-time (path file)))

(define (changed? file)
  (not (= (fs-mtime file) (mtime file))))

(define (update! file)
  (inc! (counter file))
  (set! (mtime file) (fs-mtime file)))

(define (utime file)
  ;; friendly (user) time -> hh:mm:ss
  (let* ((date (seconds->local-time (mtime file)))
         (ref (lambda (n)
                (let ((x (vector-ref date n)))
                  ;; pad with 0
                  (if (< x 10)
                      (conc "0" x)
                      x)))))
    ;; hh:mm:ss
    (conc (ref 2) ":" (ref 1) ":" (ref 0))))

(define (load-1 file)
  (update! file)
  (handle-exceptions
   exn
   (begin
     (prn "E:" (counter file) " [" (path file) "]")
     (print-error-message exn))
   (begin
     (load (path file))
     (prn "@:" (counter file) " [" (path file) "] " (utime file)))))

(define (make-scanner paths)
  (let ((files
         (map (lambda (path)
                ;; force initial load (mtime = 0)
                (make-file path 0 0))
              paths)))
    (lambda ()
      (for-each (lambda (file)
                  (when (changed? file)
                    (load-1 file)))
                files))))

(define (%rl . paths)
  (let ((scan! (make-scanner paths)))
    (thread-start!
     (lambda ()
       (let loop ()
         (scan!)
         (thread-sleep! 0.75)
         (loop))))))

;;; [export]

(set! rl %rl)

) 
