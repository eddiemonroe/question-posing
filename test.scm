(use-modules
  (opencog)
  (opencog exec)
  (opencog nlp)
  (opencog nlp chatbot)
  (opencog nlp relex2logic)
  (opencog nlp sureal)
  (srfi srfi-1) ; needed for delete-duplicates
)


(define (sent-get-tense sentence)
  (define (bl-for-sent sent)
    (Bind
      (VariableList
        (TypedVariableLink
          (Variable "$word-instance")
          (TypeNode "WordInstanceNode"))
        (TypedVariableLink
          (Variable "$dlc")
          (TypeNode "DefinedLinguisticConceptNode"))
        (TypedVariableLink
          (Variable "$parse")
          (TypeNode "ParseNode"))
      )
      (And
        (ParseLink
          (Variable "$parse")
          sentence)
        (WordInstanceLink
          (Variable "$word-instance")
          (Variable "$parse"))
        (TenseLink
          (Variable "$word-instance")
          (Variable "$dlc")))
      (Variable "$dlc")))

  (let*
     ((sentence
      (if (list? sentence)
        (car sentence)
        sentence))
      (bl (bl-for-sent sentence))
      (results (cog-execute! bl)))

    (gar results)))
    ;
    ; (if (not (null? (gar results)))
    ;   (cog-name (gar results))
    ;   '()))


  ; (set! sentence
  ;   (if (list? sentence)
  ;     (car sentence)
  ;     sentence))

  ; (define bl (bl-for-sent sentence))
  ;   ;; sentence should be a SentenceNode, but if arg wsa sent as a list (e.g.,
  ;   ;; nlp-parse returns SentenceNodes wrapped in a list), grab the Sentence
  ;   ;; from the list)
  ;   ;; Todo: Handle multiple sentences returned from nlp-parse?
  ;   ; (if (list? sentence)
  ;   ;   (car sentence)
  ;   ;   sentence)))
  ;
  ;
  ; (define results (cog-execute! bl))
  ;
  ; (if (not (empty? (gar results)))
  ;   (cog-name (gar results))
  ;   '()))

  ; (let ((results))
  ;   (cog-execute!
  ;
  ;
  ;   (if (not (empty? (gar results)))
  ;     (cog-name (gar results))
  ;     '())))





#!
;; replacing "I" for "you"

(define e
  (Evaluation
    (Predicate "like")
    (List
      (Concept "I")
      (Concept "smoothies"))))

;; Replace "I" with "you" for predicate arguments
;; Assumes args are wrapped in a ListLink
(define (replace-I-with-you orig-eval)
  (define nodes (cog-get-all-nodes orig-eval))
  (if (member (Concept "I") nodes)
    (begin
      (format #t "found one in ~a\n" orig-eval)
      ;; for now assuming it's Eval Pred List arguments
      (let* ((pred (gar orig-eval))
             (args (cog-outgoing-set (gdr orig-eval)))
             (new-args '()))
             ; (new-eval '())))
        (set! new-args
          (map
            (lambda (arg)
              (if (and (eq? (cog-type arg) 'ConceptNode)
                       (equal? (cog-name arg) "I"))
                (Concept "you")
                arg))
            args))

        (Evaluation
          pred
          (List new-args))))
    orig-eval)
)

(define replace replace-I-with-you)
    ; (define new-eval
    ;   (Eval))

  ; (define list (gdr eval))
  ; (define args (cog-outgoing-set list))
  ; (foreach (lambda (arg)
  ;             (if (and (eq? (cog-get-type arg) 'ConceptNode)
  ;                      (equal? (cog-name arg) "I"))
  ;
  ;                 )))



#!
;; Reproduce problem with passing past tense pred to sureal

; sureal preparsing
(nlp-parse "Did you want to swim?")
(nlp-parse "to relax")
(nlp-parse "You wanted to relax?")

; logic in present tense of "want"
(define present    (EvaluationLink (stv 1 1)
       (PredicateNode "want" (stv 9.7569708e-13 0.0012484395))
       (ListLink
          (ConceptNode "you")
          (PredicateNode "relax" (stv 9.7569708e-13 0.0012484395))
       )
    )
 )

; logic in past tense of "want"
(define past    (EvaluationLink (stv 1 1)
      (PredicateNode "wanted" (stv 9.7569708e-13 0.0012484395))
      (ListLink
         (ConceptNode "you")
         (PredicateNode "relax" (stv 9.7569708e-13 0.0012484395))
      )
   )
)

; Sureal sentence generation for atomese logic representation
(define (sureal-for-logic logic)
  (sureal
    (Set
      logic
      (Inheritance
        (InterpretationNode "blah")
        (DefinedLinguisticConcept "TruthQuerySpeechAct"))
      ; (Inheritance
      ;  (gar logic) (DefinedLinguisticConcept "past"))

    )))



(format #t "present: ~a\n" (sureal-for-logic present))
; $3 = (("did" "you" "want" "to" "relax" "?"))
(format #t "past: ~a\n" (sureal-for-logic past))
; $4 = ()

!#
