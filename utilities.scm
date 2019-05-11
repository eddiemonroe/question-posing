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

(load "rules.scm") ; used by text-get-r2l-abstract

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
  (apply-rule-to-focus-set r2l-abstract-rule focus-set))

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
    (cog-execute! r2l-abstract-rule)))
    ; ))
  ; (cog-cp focus-set temp-as)
  ; (cog-set-atomspace! temp-as)
  ; (set! results (cog-execute! r2l-abstract-rule))

  ;; Copy the result atoms into the original atomspace
  ;; Below does not work for us here because we to return valid handles to the
  ;; result atoms in the original atomspace.
  ; (cog-cp utter-abstract orig-as)

  ;; Creating a Set in the original atomspace results in it'scontents being
  ;; created there as well.
  (cog-set-atomspace! orig-as)
  (set! results (Set (cog-outgoing-set results)))

  ;; Now go back and clear the temp-as
  (cog-set-atomspace! temp-as)
  (clear)
  (cog-set-atomspace! orig-as)

  results)

;; Notes the below relies on get-abstract-version in relex2logic/post-processing.scm.
;; That procedure intentially does not abstract definite nouns, so is probably not
;; useful for the present purposes. E.g., For "He saw the movie." 'movie' does
;; not get abstacted, but for "He saw a movie." 'movie' does get abstracted. Note
;; also that pronouns never get abstracted. Potential solution: include all or
;; some definites in a similar function. Or use a BL rule based approach.
(define (text-get-abstract-version text)
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
