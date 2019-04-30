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

; --- Knowledge --- ;
(ImplicationScope (stv 1 1)
  (TypedVariable
    (Variable "$PersonX")
    (Type "ConceptNode"))
  (Evaluation
    (Predicate "watch")
    (List
      (Variable "$PersonX")
      (Concept "movie")))
  (Evaluation
    (Predicate "want")
    (List
      (Variable "$PersonX")
      (Concept "relax"))))

(ImplicationScope (stv 1 1)
  (TypedVariable
    (Variable "$PersonX")
    (Type "ConceptNode"))
  (Evaluation
    (Predicate "watch")
    (List
      (Variable "$PersonX")
      (Concept "movie")))
  (Evaluation
    (Predicate "entertained")
    (List
      (Variable "$PersonX"))))

; --- Rules --- ;

; For R2L predicates, substitute predicates and concepts based on particular word
; instances with their generalized names.
(define r2l-abstract-rule
  (Bind
    (VariableList
      (TypedVariable
        (Variable "$pred-inst")
        (Type "PredicateNode"))
      (TypedVariable
        (Variable "$pred")
        (Type "PredicateNode"))
      (TypedVariable
        (Variable "$concept1-inst")
        (Type "ConceptNode"))
      (TypedVariable
        (Variable "$concept1")
        (Type "ConceptNode"))
      (TypedVariable
        (Variable "$concept2-inst")
        (Type "ConceptNode"))
      (TypedVariable
        (Variable "$concept2")
        (Type "ConceptNode")))
    (And
      (Evaluation
        (Variable "$pred-inst")
        (List
          (Variable "$concept1-inst")
          (Variable "$concept2-inst")))
      (Implication
        (Variable "$pred-inst")
        (Variable "$pred"))
      (Inheritance
        (Variable "$concept1-inst")
        (Variable "$concept1"))
      (Inheritance
        (Variable "$concept2-inst")
        (Variable "$concept2")))
    (Evaluation
      (Variable "$pred")
      (List
        (Variable "$concept1")
        (Variable "$concept2")))))

; --- Input Utterance --- ;
;; Parse the input utterance
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
(cog-cp utter-abstract main-as)
; (clear)   ; for now, keep the handle valid for debugging purposes
(cog-set-atomspace! main-as)


;; Experimental approach using DualLink to target instantiated Implications
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

; Conditional full instantiation rule method

;; For now, lead the "standard" pln rule base
(pln-load)


