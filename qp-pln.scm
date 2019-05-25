; Proof of concept question posing in response to utterance based on background
; knowledge and reasoning

(use-modules
  (opencog)
  (opencog exec)
  (opencog nlp)
  (opencog nlp chatbot)
  (opencog nlp relex2logic)
  (opencog nlp sureal)
  (opencog pln)
  (opencog ure)
  (srfi srfi-1)
)

;; Load the background Knowledge
(load "knowledge.scm")

;; Load rules particular to question processing
(load "rules.scm")

;Pre-parsed sentences for Sureal
(load "sureal-preparse.scm")

(load "utilities.scm")

; --- Input Utterance --- ;
;; Parse the input utterance
;; Todo: Handle multiple sentence interpretations
(define utterances (list
  "I watched a movie"
  "The man died."
))

(define (questions-for-utterance text)
  (define kb-conclusions '())
  (define questions '())

  ;; Transorm utterance text to abastact logical atomese form
  (define utter-logic (text-get-r2l-abstract text))

  ;; Temp hacky way to convert "I" Concepts to "you"
  (set! utter-logic (replace-i-with-you utter-logic))

  ;; Set confidence values above 0 for instantiation rules
  (for-each
    (lambda (eval-link) (cog-set-tv! eval-link (stv 1 1)))
    utter-logic)

  (format #t "\nutter-logic:\n ~a\n" utter-logic)

  ;; PLN reasoning to derive knowledge-based conclusions from utterance
  (set! kb-conclusions (conclusions-for-utter-logic utter-logic))
  (display "YOU ARE HERE\n")

  ;; Wrap Predicate args in List where needed for sureal bug
  (set! kb-conclusions
    (map add-list-to-eval (cog-outgoing-set kb-conclusions)))
  (format #t "kb-conclusions 1:\n~a\n" kb-conclusions)

  ; Generate the responses with SuReal
  (set! questions
    (append-map
      sureal-for-logic
      kb-conclusions))

  (format #t "generated questions:\n~a\n" questions)
)

(define (conclusions-for-utter-logic utter-logic)
  ;; For now, load the "standard" pln rule base
  (pln-load)
(display "AND HERE TOO\n")
  ;; Results in BL's for every ImplicationScope in the KB
  ;; Todo: We will need a more opticmal way to do this with the full KB
  (meta-bind conditional-full-instantiation-implication-scope-meta-rule)
  ; (format #t "kb-conclusions:\n~a\n" kb-conclusions)
)

;; Temp hack to workaround sureal bug for Eval's without List for args
(define (add-list-to-eval eval)
  (if (not (equal? (cog-type (gdr eval)) 'ListLink))
  ;; Assumption: if no List for arg, then we know it is a single argument,
  ;; though this will be changing, i.e., mult Eval args without list
  (let ([pred (gar eval)]
    [arg (gdr eval)])
    (Evaluation pred (List arg)))
    eval))

;; -------------------------------
;; Shortcuts for testing

(define q questions-for-utterance)





; (for-each questions-for-utterance utterances)




; (define utter-sent (car (nlp-parse utterance)))
;
; (define utter-logic (sent-get-r2l-outputs utter-sent))
;
;
; ;; We need to form an abstracted version of the utterance r2l
;
; ;; MapLink doesn't work for this b/c it tries to match each r2l piece separately
; ;; rather than as a whole.
; ;(define r2l-abstract-map
; ;  (Map
; ;    r2l-abstract-map-rule
; ;    utter-logic))
;
; ;; Apply the r2l-abstract-rule just to the utterance r2l (rather than globally)
; (define utter-abstract
;   (apply-r2l-abstract-rules-to-focus-set utter-logic))
;
; (format #t "utterance abstract: ~a\n" utter-abstract)
;
; ;; Temp hacky way to convert "I" to "you"
; ;; Doing this after the pln inference on the conclusions now
; ; (set! utter-abstract (cog-execute! i-to-you-rule))
; ; (set! utter-abstract (cog-outgoing-set (cog-execute! i-to-you-rule-2-args)))
; ; (set! utter-abstract (apply-rules-to-focus-set i-to-you-rules utter-abstract))
;
; ; (format #t "utterance abstract: ~a\n" utter-abstract)
;
; ;; Set confidence values above 0 for instantiation rules
; (for-each
;   (lambda (eval-link) (cog-set-tv! eval-link (stv 1 1)))
;   utter-abstract)


;; Experimental approach wip using DualLink to target instantiated Implications
;; Let's try the approach of grabbing the potentially applicable background
;; knowledge by getting Implication links with premises matching utter r2l
#!
(define dl
  (Dual (gar utter-abstract)))

(define matched-pattern (cog-execute! dl))

;; Then what is best way to instantiate (just based on matched patterns)

;(define dltest
;  (Dual
;    (ImplicationScope
;      (Variable "$VarDecl")
;      (gar utter-abstract)
;      (Variable "$Implicand"))))
!#

; ;; ---------------------------------------------
; ;; Conditional full instantiation rule method
;
; ;; For now, lead the "standard" pln rule base
; (pln-load)
;
; ;; Results in BL's for every ImplicationScope in the KB
; (define kb-conclusions
;   (meta-bind conditional-full-instantiation-implication-scope-meta-rule))
; ; (format #t "kb-conclusions:\n~a\n" kb-conclusions)
;
; ; Testing
; ;; This creates BindLink rules for each ImplicationScopeLink
; ;; Do we instead just want to grab matching Implications and create BL's on the fly?
; ;;(define rules (cog-execute!
; ;;conditional-full-instantiation-implication-scope-meta-rule))

;; -------------------------------------
;; Sureal question generation


; (set! kb-conclusions
;   ; (Set (map add-list-to-eval (cog-outgoing-set kb-conclusions))))
;   (map add-list-to-eval (cog-outgoing-set kb-conclusions)))
; (format #t "kb-conclusions 1:\n~a\n" kb-conclusions)
;
;
; ;; Temp hacky way to convert "I" to "you"
; (set! kb-conclusions (replace-i-with-you kb-conclusions))
; ;(set! kb-conclusions (cog-execute! i-to-you-rule-2-args))
; ;(set! kb-conclusions (apply-rules-to-focus-set i-to-you-rules kb-conclusions))
;
; (format #t "kb-conclusions 2:\n~a\n" kb-conclusions)
;
; ; (set! utter-abstract (cog-execute! i-to-you-rule))
;
;
; ; Generate the sentence
; (define questions
;   (append-map
;     sureal-for-logic
;     ; (lambda (result-logic)
;     ;   (sureal
;     ;     (Set
;     ;       result-logic
;     ;       (Inheritance (InterpretationNode "blah") (DefinedLinguisticConcept "TruthQuerySpeechAct")))))
;     kb-conclusions))
;
; (format #t "generated questions:\n~a\n" questions)

;; ---------------------------------------
;; Testing

; (define r1 (gar kb-conclusions))
; (define r2 (gdr kb-conclusions))
#!
(define rlist
  (Evaluation
    (gar r1)
    (List
      (gdr r1))))
!#
