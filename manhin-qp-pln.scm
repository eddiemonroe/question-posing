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

; For "I" -> "You"
; TODO: Should be a bit more sophisticated?
; e.g. further reduce $concept1 to face-id-x
; in r2l-abstract-rule, since we know we are
; talking to face-id-x so turn face-id-x to "you"
(ImplicationScope (stv 1 1)
  (VariableList
    (TypedVariable
      (Variable "$any-pred")
      (Type "PredicateNode"))
    (TypedVariable
      (Variable "$any-concept")
      (Type "ConceptNode")))
  (Evaluation
    (Variable "$any-pred")
    (List
      (Concept "I")
      (Variable "$any-concept")))
  (Evaluation
    (Variable "$any-pred")
    (List
      (Concept "you")
      (Variable "$any-concept"))))

; --- Rules --- ;
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

; TODO: Replaced by wip/implication-instantiation (?)
(define pln-sketch-implication-instantiation-rule
  (Bind
    (TypedVariable
      (Variable "$implication-scope")
      (Type "ImplicationScopeLink"))
    (Variable "$implication-scope")
    (ExecutionOutput
      (GroundedSchema "scm: pln-sketch-implication-instantiation-formula")
      (Variable "$implication-scope"))))

; Schema to instantiate an ImplicationScopeLink
(define-public
  (pln-sketch-implication-instantiation-formula implication-scope-link)
    (Bind (cog-outgoing-set implication-scope-link)))

; --- Input Utterance --- ;
; Parse the input utterance
(define utterance (car (nlp-parse "I watched a movie")))

; Some URE setup
(define rule-base (ConceptNode "pln-sketch-rule-base"))
(ure-define-rbs rule-base 10)
(ure-set-fuzzy-bool-parameter rule-base "URE:attention-allocation" 0)

;For SuReal
(nlp-parse "were you interested?")
(nlp-parse "I am entertained")
(nlp-parse "I wanted to relax")

; Start loading and adding rules to the rule base
; TODO: Rules that work on the implication level e.g. conditional-full-instantiation meta-rule, modus ponens etc?
(map
  (lambda (bind-link)
    (ure-define-add-rule
      rule-base
      (string-append "pln-sketch-implication-instantiation-rule-" (random-string 10))
      bind-link
      (stv 1 1)))
  (cog-outgoing-set (cog-execute! pln-sketch-implication-instantiation-rule)))

; Get the abstracted form of the input utterance
(define source (cog-execute! r2l-abstract-rule))

; Do forward chaining
(define fc-results (cog-fc rule-base source))

; TODO: How to pick the preferable one(s)?

; Generate the sentence
(define sentences
  (append-map
    (lambda (result)
      (format #t "result: ~a\n" result)
      (sureal
        (Set
          result
          ; TODO: How to choose speech act?
          (Inheritance (InterpretationNode "blah") (DefinedLinguisticConcept "TruthQuerySpeechAct")))))
    (cog-outgoing-set fc-results)))

(format #t "Forward Chainer:\n~a\nSuReal:\n~a\n" fc-results sentences)
