;; This assumes that single-argument Predicates don't need a List to wrap the arg

(use-modules
  (opencog)
  (opencog exec)
  (opencog nlp)
  (opencog nlp chatbot)
  (opencog nlp relex2logic)
  (opencog nlp sureal))

(define (sureal-for-logic logic)
  (sureal
    (Set
      logic
      (Inheritance
        (InterpretationNode "blah")
        (DefinedLinguisticConcept "TruthQuerySpeechAct")))))

(define (sureal-for-text text)
  (sureal-for-logic (text-get-r2l-abstract text)))

;---------------------------------------

(nlp-parse "Did Emosi cry?")
(nlp-parse "Did personx cry?")
(nlp-parse "Did person cry?")
(nlp-parse "Emosi")

(define you
  (EvaluationLink
     (PredicateNode "cry")
     (ListLink
        (ConceptNode "person"))))

(define andy
  (EvaluationLink
     (PredicateNode "cry")
     (ListLink
        (ConceptNode "Emosi"))))

(sureal-for-logic you)
(sureal-for-logic andy)

;---------------------------------------
#!
;; No list wrapping arg bug
(define with-list
  (EvaluationLink
     (PredicateNode "entertained")
     (ListLink
        (ConceptNode "you"))))

(define no-list
  (EvaluationLink
    (PredicateNode "entertained")
    (ConceptNode "you")))

(define (sureal-for-logic logic)
  (sureal
    (Set
      logic
      (Inheritance
        (InterpretationNode "blah")
        (DefinedLinguisticConcept "TruthQuerySpeechAct")))))

; pre-parse for sureal sentance generation
(nlp-parse "Were you entertained?")

(format #t "\nWith List result:\n~a\n" (sureal-for-logic with-list))
(format #t "\nNo List result:\n~a\n\n" (sureal-for-logic no-list))

!#
