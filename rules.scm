; --- Rules for question posing --- ;

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

;; Hacky rule to substitute "you" for "I"
(define i-to-you-rule
  (Bind
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
        (Variable "$any-concept")))))
