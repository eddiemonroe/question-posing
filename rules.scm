; --- Rules for question posing --- ;

;; For R2L predicates, substitute predicates and concepts based on particular word
;; instances with their generalized names.
;; New rules of this type should be added to the r2l-abstract-rules list below

;; For single argument Predicates
(define r2l-abstract-rule-1-arg
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
    )
    (And
      (Evaluation
        (Variable "$pred-inst")
        (List
          (Variable "$concept1-inst")))
      (Implication
        (Variable "$pred-inst")
        (Variable "$pred"))
      (Inheritance
        (Variable "$concept1-inst")
        (Variable "$concept1")))
    (Evaluation
      (Variable "$pred")
      (List
        (Variable "$concept1")))))

;; For 2 argument predicates
(define r2l-abstract-rule-2-args
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
        (Variable "$concept-or-pred-inst")
        (TypeChoice
          (Type "ConceptNode")
          (Type "PredicateNode")))
      (TypedVariable
        (Variable "$concept-or-pred")
        (TypeChoice
          (Type "ConceptNode")
          (Type "PredicateNode")))
    )
    (And
      (Evaluation
        (Variable "$pred-inst")
        (List
          (Variable "$concept1-inst")
          (Variable "$concept-or-pred-inst")))
      (Implication
        (Variable "$pred-inst")
        (Variable "$pred"))
      (Inheritance
        (Variable "$concept1-inst")
        (Variable "$concept1"))
      (Choice
        (Inheritance
          (Variable "$concept-or-pred-inst")
          (Variable "$concept-or-pred"))
        (Implication
          (Variable "$concept-or-pred-inst")
          (Variable "$concept-or-pred"))))
    (Evaluation
      (Variable "$pred")
      (List
        (Variable "$concept1")
        (Variable "$concept-or-pred")))))

;; List of the r2l-abstract-rules.
;; New rules of this type should be added to this list.
(define r2l-abstract-rules
  (list
    r2l-abstract-rule-1-arg
    r2l-abstract-rule-2-args))

;; Hacky rule to substitute "you" for "I"
(define i-to-you-rule-1-arg
  (Bind
    (VariableList
      (TypedVariable
        (Variable "$any-pred")
        (Type "PredicateNode")))
    (Evaluation
      (Variable "$any-pred")
      (List
        (Concept "I")))
    (Evaluation
      (Variable "$any-pred")
      (List
        (Concept "you")))))

(define i-to-you-rule-2-args
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

(define i-to-you-rules
  (list
    i-to-you-rule-1-arg
    i-to-you-rule-2-args))
