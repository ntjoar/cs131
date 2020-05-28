#lang racket
(current-namespace (make-base-namespace))
(provide (all-defined-out))

;Problem 1
;main function
(define (expr-compare x y)
  (define dictionary (dict-set #hash() '() '()))
  (cond
    [(list? x) (if (list? y)
                       (clean-y (comp_li x y) (clean-x (comp_li x y) dictionary))
                       (cons 'if (cons '% (cons x (cons y '())))))]
    [(list? y) (cons 'if (cons '% (cons x (cons y '()))))]
    [else (compare_val x y)]))

;compares two values
(define (compare_val val1 val2)
  (cond
    [(equal? val1 val2) val1]
    [(boolean? val1) (if val1
                          '%
                          '(not %))]
    #|[(or (and (equal? 'lambda val1) (equal? 'λ val2))
         (and (equal? 'lambda val2) (equal? 'λ val1)))
     'λ]|#
    [(and (list? val1) (list? val2)) (comp_li val1 val2)]
    [else
     (cons 'if (cons '% (cons val1 (cons val2 '()))))]))

;compares each element in two lists
(define (comp_li list1 list2)
  (reverse (comp_li_helper list1 list2 '())))

(define (comp_li_helper list1 list2 acc)
  (cond
    [(not (equal? (length list1) (length list2))) (reverse (cons 'if (cons '% (cons list1 (cons list2 '())))))]
    [(or (empty? list1) (empty? list2)) acc]
    [(or (and (is_lam (car list1)) (not (is_lam (car list2))))
         (and (is_lam (car list2)) (not (is_lam (car list1)))))
     (reverse (cons 'if (cons '% (cons (cons 'λ (cdr list1)) (cons list2 '())))))]
    [(and (is_lam (car list1)) (is_lam (car list2)) (equal? (length list1) (length list2)) (> (length list1) 2)) (if (not (equal? (length (cadr list1)) (length (cadr list2))))
                                                                                                                           (reverse (cons 'if (cons '% (cons (cons 'λ (cdr list1)) (list (cons 'λ (cdr list2)))))))
                                                                                                                           (reverse (comp_lam list1 list2)))]
    [(equal? (car list1) (car list2)) (if (can_merge (car list1))
                                          (comp_li_helper (cdr list1) (cdr list2) (cons (compare_val (car list1) (car list2)) acc))
                                          (reverse (cons 'if (cons '% (cons list1 (cons list2 '()))))))]
    [(or (equal? (car list1) 'if) (equal? (car list2) 'if)) (reverse (cons 'if (cons '% (cons list1 (cons list2 '())))))]
    [else
     (comp_li_helper (cdr list1) (cdr list2) (cons (compare_val (car list1) (car list2)) acc))]))

;determines if we can combine the objects based on their type
(define (can_merge kw)
  (cond
    [(equal? kw 'list) #f]
    [(equal? kw 'quote) #f]
    [else #t]))

;cleans expression by replacing anything possible
(define (clean-x exp dictionary)
  (cond 
   [(equal? exp '()) dictionary]
   [(and (list? (car exp)) (= (length (car exp)) 4) (equal? (caar exp) 'if) (equal? (cadr (car exp)) '%))
                           (if (dict-has-key? dictionary (car exp))
                               (let ([new-dict (dict-set dictionary (car exp) (+ 1 (dict-ref dictionary (car exp))))]) (clean-x (cdr exp) new-dict))
                               (let ([new-dict (dict-set dictionary (car exp) 1)]) (clean-x (cdr exp) new-dict)))]
   [(list? (car exp)) (clean-x (cdr exp) (clean-x (car exp) dictionary))]
   [else (clean-x (cdr exp) dictionary)]))

(define (clean-y exp dictionary)
  (cond
    [(equal? exp '()) '()]
    [(and (= (length exp) 4) (equal? (car exp) 'if) (equal? (cadr exp) '%)) (if (and (dict-has-key? dictionary exp) (> (dict-ref dictionary exp) 1))
                                                                                   (make_bound (caddr exp) (cadddr exp))
                                                                                   exp)]
    [(list? (car exp)) (cons (clean-y (car exp) dictionary) (clean-y (cdr exp) dictionary))]
   [else (cons (car exp) (clean-y (cdr exp) dictionary))]))
                                                                                   

;compares two lambda functions
(define (comp_lam list1 list2)
  (define dictionary (dict-set #hash() '() '()))
  (let ([new-dict1 (pop_dict0 (cadr list1) (cadr list2) dictionary)]
        [new-dict2 (pop_dict1 (cadr list1) (cadr list2) dictionary)])
  (cons 'λ (cons (comp_lam_helper (modify1 (cadr list1) new-dict1) (modify2 (cadr list2) new-dict2) '())
                 (comp_lam_helper (modify1 (cddr list1) new-dict1) (modify2 (cddr list2) new-dict2) '())))))

(define (comp_lam_helper list1 list2 acc)
  (cond
    [(or (empty? list1) (empty? list2)) (reverse acc)]
    [(and (list? (car list1)) (list? (car list2))) (if (and (is_lam (caar list1)) (is_lam (caar list2)))
                                                       (comp_lam_helper (cdr list1) (cdr list2) (cons (comp_lam (car list1) (car list2)) acc))
                                                       (comp_lam_helper (cdr list1) (cdr list2) (cons (comp_lam_helper (car list1) (car list2) '()) acc)))]
    [(equal? (car list1) (car list2))
     (comp_lam_helper (cdr list1) (cdr list2) (cons (car list1) acc))]
    [else
     (comp_lam_helper (cdr list1) (cdr list2) (cons (compare_val (car list1) (car list2)) acc))]))

;checks if lambda
(define (is_lam val)
  (cond
    [(or (equal? val 'λ) (equal? val 'lambda)) #t]
    [else #f]))

;makes two variables bound
(define (make_bound var1 var2)
  (string->symbol (fix_bound (string-append (symbol->string var1) (string-append "!" (symbol->string var2))))))

;fixes the case where bound variables actually don't need to be
(define (fix_bound bound_str)
  (let ([substr_list (string-split bound_str "!")]) 
  (cond
    [(equal? (list-ref substr_list 0) (list-ref substr_list (- (length substr_list) 1)))
     (list-ref substr_list 0)]
    [else
     bound_str])))

;modifies list1 for bound variables
(define (modify1 list dictionary)
  (cond
    [(equal? empty list)
     '()]
    [(symbol? list) (if (dict-has-key? dictionary list)
                        (cons (make_bound list (dict-ref dictionary list)) '())
                        (cons list '()))]
    [(list? (car list)) (cons (modify1 (car list) dictionary) (modify1 (cdr list) dictionary))]
    [(dict-has-key? dictionary (car list))
     (cons (make_bound (car list) (dict-ref dictionary (car list))) (modify1 (cdr list) dictionary))]
    [else
     (cons (car list) (modify1 (cdr list) dictionary))]))

;modifies list2 for bound variables
(define (modify2 list dictionary)
  (cond
    [(equal? empty list)
     '()]
    [(symbol? list) (if (dict-has-key? dictionary list)
                        (cons (make_bound list (dict-ref dictionary list)) '())
                        (cons list '()))]
    [(list? (car list)) (cons (modify2 (car list) dictionary) (modify2 (cdr list) dictionary))]
    [(dict-has-key? dictionary (car list))
     (cons (make_bound (dict-ref dictionary (car list)) (car list)) (modify2 (cdr list) dictionary))]
    [else
     (cons (car list) (modify2 (cdr list) dictionary))]))

;populates dictionary1 with mappings from first lambda's arguments to second lambda's arguments
(define (pop_dict0 args1 args2 dictionary)
  (cond
    [(or (equal? args1 empty) (equal? args2 empty)) dictionary]
    [(and (symbol? args1) (symbol? args2))
     (if (equal? args1 args2)
         dictionary
         (dict-set dictionary args1 args2))]
    [(equal? (car args1) (car args2))
     (pop_dict0 (cdr args1) (cdr args2) dictionary)]
    [else
     (let ([new-dict (dict-set dictionary (car args1) (car args2))]) 
     (pop_dict0 (cdr args1) (cdr args2) new-dict))]))

;populates dictionary2 with mappings from second lambda's arguments to first lambda's arguments
(define (pop_dict1 args1 args2 dictionary)
  (cond
    [(or (equal? args1 empty) (equal? args2 empty)) dictionary]
    [(and (symbol? args1) (symbol? args2))
     (if (equal? args1 args2)
         dictionary
         (dict-set dictionary args2 args1))]
    [(equal? (car args1) (car args2))
     (pop_dict1 (cdr args1) (cdr args2) dictionary)]
    [else
     (let ([new-dict (dict-set dictionary (car args2) (car args1))]) 
     (pop_dict1 (cdr args1) (cdr args2) new-dict))]))


;Problem 2
(define (replace list replaced replacement)
  (cond
    [(equal? list empty) '()]
    [(list? (car list)) (cons (replace (car list) replaced replacement) (replace (cdr list) replaced replacement))]
    [(equal? (car list) replaced) (cons replacement (replace (cdr list) replaced replacement))]
    [else (cons (car list) (replace (cdr list) replaced replacement))]))

(define (test-expr-compare x y)
  (let ([result (expr-compare x y)])
  (cond
    [(equal? (eval (replace result '% '#t)) (eval (replace result '% '#f))) '#t]
    [else '#f])))

;Problem 3
(define test-expr-x '(+ 1 ((lambda (a b) (+ a b)) 3 ((λ (c) (* 2 c)) 1))))
(define test-expr-y '(+ 1 ((λ (x y) (+ x y)) 3 ((lambda (c) (* c 2)) 1))))

;(test-expr-compare test-expr-x test-expr-y)

(expr-compare 12 12);  ⇒  12
(expr-compare 12 20);  ⇒  (if % 12 20)
(expr-compare #t #t);  ⇒  #t
(expr-compare #f #f);  ⇒  #f
(expr-compare #t #f);  ⇒  %
(expr-compare #f #t);  ;⇒  (not %)
(expr-compare 'a '(cons a b))  ;⇒  (if % a (cons a b))
(expr-compare '(cons a b) '(cons a b))  ;⇒  (cons a b)
(expr-compare '(cons a lambda) '(cons a λ))  ;⇒  (cons a (if % lambda λ))
(expr-compare '(cons (cons a b) (cons b c))
              '(cons (cons a c) (cons a c)))
  ;⇒ (cons (cons a (if % b c)) (cons (if % b a) c))
(expr-compare '(cons a b) '(list a b))  ;⇒  ((if % cons list) a b)
(expr-compare '(list) '(list a))  ;⇒  (if % (list) (list a))
(expr-compare ''(a b) ''(a c))  ;⇒  (if % '(a b) '(a c))
(expr-compare '(quote (a b)) '(quote (a c)))  ;⇒  (if % '(a b) '(a c))
(expr-compare '(quoth (a b)) '(quoth (a c)))  ;⇒  (quoth (a (if % b c)))
(expr-compare '(if x y z) '(if x z z))  ;⇒  (if x (if % y z) z)
(expr-compare '(if x y z) '(g x y z))
  ;⇒ (if % (if x y z) (g x y z))
(expr-compare '((lambda (a) (f a)) 1) '((lambda (a) (g a)) 2))
  ;⇒ ((lambda (a) ((if % f g) a)) (if % 1 2))
(expr-compare '((lambda (a) (f a)) 1) '((λ (a) (g a)) 2))
  ;⇒ ((λ (a) ((if % f g) a)) (if % 1 2))
(expr-compare '((lambda (a) a) c) '((lambda (b) b) d))
  ;⇒ ((lambda (a!b) a!b) (if % c d))
(expr-compare ''((λ (a) a) c) ''((lambda (b) b) d))
  ;⇒ (if % '((λ (a) a) c) '((lambda (b) b) d))
(expr-compare '(+ #f ((λ (a b) (f a b)) 1 2))
              '(+ #t ((lambda (a c) (f a c)) 1 2)))
  ;⇒ (+
    ;  (not %)
    ;  ((λ (a b!c) (f a b!c)) 1 2))
(expr-compare '((λ (a b) (f a b)) 1 2)
              '((λ (a b) (f b a)) 1 2))
  ;⇒ ((λ (a b) (f (if % a b) (if % b a))) 1 2)
(expr-compare '((λ (a b) (f a b)) 1 2)
              '((λ (a c) (f c a)) 1 2))
  ;⇒ ((λ (a b!c) (f (if % a b!c) (if % b!c a)))
    ;  1 2)
(expr-compare '((lambda (lambda) (+ lambda if (f lambda))) 3)
              '((lambda (if) (+ if if (f λ))) 3))
  ;⇒ ((λ (lambda!if) (+ lambda!if (% if lambda!if (f (if % lambda!if λ))) 3)
(expr-compare '((lambda (a) (eq? a ((λ (a b) ((λ (a b) (a b)) b a))
                                    a (lambda (a) a))))
                (lambda (b a) (b a)))
              '((λ (a) (eqv? a ((lambda (b a) ((lambda (a b) (a b)) b a))
                                a (λ (b) a))))
                (lambda (a b) (a b))))
  ;⇒ ((λ (a)
    ;   ((if % eq? eqv?)
    ;    a
    ;    ((λ (a!b b!a) ((λ (a b) (a b)) (if % b!a a!b) (if % a!b b!a)))
    ;     a (λ (a!b) (if % a!b a)))))
    ;  (λ (b!a a!b) (b!a a!b)))