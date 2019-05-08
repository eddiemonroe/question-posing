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

; --- Input Utterance --- ;
;; Parse the input utterance
;; Todo: Handle multiple sentence interpretations
(define utter-sent (car (nlp-parse "I watched a movie")))

(define utter-logic (sent-get-r2l-outputs utter-sent))


;; We need to form an abstracted version of the utterance r2l

;; MapLink doesn't work for this b/c it tries to match each r2l piece separately
;; rather than as a whole.
;(define r2l-abstract-map
;  (Map
;    r2l-abstract-map-rule
;    utter-logic))

;; Apply the r2l-abstract-rule just to the utterance r2l (rather than globally)
;; Create temp atomspace do do this. (Alternatively could use one-step forward-
;; chaining with focus set.)
(define main-as (cog-atomspace))
(define temp-as (cog-new-atomspace))
(cog-cp utter-logic temp-as)
(cog-set-atomspace! temp-as)
(define utter-abstract (cog-execute! r2l-abstract-rule))

;; Copy the result atoms into the main atomspace
;; below is not good because we want a handle to the atoms in the main as
; (cog-cp utter-abstract main-as)
(cog-set-atomspace! main-as)
(set! utter-abstract (Set (cog-outgoing-set utter-abstract)))

;; tag abstract form of utterance with cog key-value
;(cog-set-value! (Concept "utterance") (Concept "current-abstract")
;  utter-abstract)

;; now go back and clear the temp-as
(cog-set-atomspace! temp-as)
(clear)   ; for now, keep the handle valid for debugging purposes
(cog-set-atomspace! main-as)

;; Temp hacky way to convert "I" to "you"
(set! utter-abstract (cog-execute! i-to-you-rule))

;; Temp hack to set confidence values above 0 for instantiation rules
(for-each
  (lambda (eval-link) (cog-set-tv! eval-link (stv 1 1)))
  (cog-outgoing-set utter-abstract))



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

;; ---------------------------------------------
;; Conditional full instantiation rule method

;; For now, lead the "standard" pln rule base
(pln-load)

;; Results in BL's for every ImplicationScope in the KB
(define meta-bind-results
  (meta-bind conditional-full-instantiation-implication-scope-meta-rule))
(format #t "meta-bind-results:\n~a" meta-bind-results)

; Testing
;; This creates BindLink rules for each ImplicationScopeLink
;; Do we instead just want to grab matching Implications and create BL's on the fly?
(define rules (cog-execute!
  conditional-full-instantiation-implication-scope-meta-rule))

;; -------------------------------------
;; Surreal question generation

  ;For SuReal
  (nlp-parse "were you interested?")
  (nlp-parse "I am entertained")
  (nlp-parse "I wanted to relax")
