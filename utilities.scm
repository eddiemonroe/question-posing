;; Utility functions for question posing experiments

(use-modules
  (opencog)
  (opencog exec)
  (opencog nlp)
  (opencog nlp chatbot)
  (opencog nlp relex2logic)
  (opencog nlp sureal)
  (srfi srfi-1) ; needed for delete-duplicates
)

;; Temp atomspace for use with apply-rule-to-focus-set. So we don't need to keep
;; recreating it every time it's needed.
(define temp-as (cog-new-atomspace))

;; required by apply-r2l-abstract-rules-to-focus-set
(load "rules.scm")

(define (text-get-sent text)
  ;; Todo: handle multipes sentences returned by nlp-parse. (Does that every happen?)
  (car (nlp-parse text)))

;; Gets a single (the first) interpretation of a text input
(define (text-get-interp text)
  (car (sent-get-interp (text-get-sent text))))

(define (text-get-r2l-output text)
  (sent-get-r2l-outputs (text-get-sent text)))

(define (text-get-r2l-abstract text)
  (define focus-set (text-get-r2l-output text))
  (apply-r2l-abstract-rules-to-focus-set focus-set))


(define (apply-rule-to-focus-set rule focus-set)
"
  Apply a single BindLink rule to a particular focus set of atoms.

  rule: a BindLink

  focus-set: a set of atoms to use to attemp to unify with the rule

  returns: the results of rule unification
"
  ;; Using temp atomspace to do this, for now at least. An alternative approach
  ;; is to use URE FC one-step with focus set.
  ; (define results)
  (define orig-as (cog-atomspace))
  (define results (begin
    (cog-cp focus-set temp-as)
    (cog-set-atomspace! temp-as)
    (cog-execute! rule)))

  ;; Copy the result atoms into the original atomspace
  ;; Below does not work for us here because we want to return valid handles to
  ;; the result atoms in the original atomspace.
  ; (cog-cp utter-abstract orig-as)

  ;; Creating a Set in the original atomspace results in its contents being
  ;; created there as well.
  (cog-set-atomspace! orig-as)
  (set! results (Set (cog-outgoing-set results)))

  ;; Now go back and clear the temp-as
  (cog-set-atomspace! temp-as)
  (clear)
  (cog-set-atomspace! orig-as)

  results)

(define (apply-rules-to-focus-set rules focus-set)
  (append-map
    (lambda (rule)
      (cog-outgoing-set
        (apply-rule-to-focus-set rule focus-set)))
    rules))

(define (apply-r2l-abstract-rules-to-focus-set focus-set)
  (apply-rules-to-focus-set r2l-abstract-rules focus-set))

  ; (append-map
  ;   (lambda (rule)
  ;     (cog-outgoing-set
  ;       (apply-rule-to-focus-set rule focus-set)))
  ;   r2l-abstract-rules))

  ; (append
  ;   (cog-outgoing-set
  ;     (apply-rule-to-focus-set r2l-abstract-rule-1-arg focus-set))
  ;   (cog-outgoing-set
  ;     (apply-rule-to-focus-set r2l-abstract-rule-2-args focus-set))))



;; Notes the below relies on get-abstract-version in relex2logic/post-processing.scm.
;; That procedure intentially does not abstract definite nouns, so is probably not
;; useful for the present purposes. E.g., For "He saw the movie." 'movie' does
;; not get abstacted, but for "He saw a movie." 'movie' does get abstracted. Note
;; also that pronouns never get abstracted. Potential solution: include all or
;; some definites in a similar function. Or use a BL rule based approach.
(define (text-get-canned-abstract-version text)
(let* ([sent (text-get-sent text)]
  [interps (sent-get-interp sent)])
  (map get-abstract-version interps)))

; Get the WordNode for the given WordInstance
(define (word-inst-get-word instance)
  (car (cog-chase-link 'ReferenceLink 'WordNode instance)))

; Use word-inst-get-lemma in relex-utils.scm instead
; Get the lemma for a given WordInstance
(define (instance-get-lemma instance)
  (car (cog-chase-link 'LemmaLink 'WordNode instance)))

;; Replace "I" with "you" for predicate arguments
;; Assumes args are wrapped in a ListLink
(define (eval-replace-i-with-you orig-eval)
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

(define (replace-i-with-you evals)
  (map eval-replace-i-with-you evals))

;--------------------------------------
; Sureal utilities

;; Sureal sentence generation for atomese logic representation
(define (sureal-for-logic logic)
  (sureal
    (Set
      logic
      (Inheritance
        (InterpretationNode "")
        (DefinedLinguisticConcept "TruthQuerySpeechAct")))))

(define (sureal-for-text text)
  (sureal-for-logic (text-get-r2l-abstract text)))

;--------------------------------------
; Shortcuts for development
(define abs text-get-r2l-abstract)
(define out text-get-r2l-output)
