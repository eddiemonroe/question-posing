(use-modules
  (opencog)
  (opencog exec)
  (opencog nlp)
;  (opencog nlp lg-parse)
;  (opencog sheaf)
;  (ice-9 optargs)
;  (ice-9 receive)
  (srfi srfi-1))



(define (parse-get-obj parse)
  (define bl
    (BindLink
      (And
        (Evaluation
          (DefinedLinguisticRelationship "_obj")
          (List (Variable "$word-inst-pred") (Variable "$word-inst-obj")))
        (WordInstanceLink (Variable "$word-inst-pred") parse)
        (WordInstanceLink (Variable "$word-inst-obj") parse)
      )

      (List (Variable "$word-inst-pred") (Variable "$word-inst-obj"))
    )
  )

 (cog-execute! bl)
)



; Get object relationships
(define bl
  (BindLink
    (And
      (Evaluation
        (DefinedLinguisticRelationship "_obj")
        (List (Variable "$word-inst-pred") (Variable "$word-inst-obj")))
      (WordInstanceLink (Variable "$word-inst-pred") parse)
      (WordInstanceLink (Variable "$word-inst-obj") parse)
    )
   (List (Variable "$word-inst-pred") (Variable "$word-inst-obj")))
)


(define bl2
  (BindLink
     (And
       (Evaluation
         (DefinedLinguisticRelationship "_obj")
         (List (Variable "$word-inst-pred") (Variable "$word-inst-obj")))
       (WordInstanceLink (Variable "$word-inst-pred") parse)
       (WordInstanceLink (Variable "$word-inst-obj") parse)
     )
     (List (Variable "$word-inst-pred") (Variable "$word-inst-obj")))
)

(Get (WordInstanceLink (Variable "$word-inst-pred") parse)



(define get2 (Get
  (And
    (Evaluation
      (DefinedLinguisticRelationship "_obj")
      (List (Variable "$word-inst-pred") (Variable "$word-inst-obj"))
    )
    (WordInstanceLink (Variable "$word-inst-pred") parse)
    (WordInstanceLink (Variable "$word-inst-obj") parse)

  )
))

 (Get (WordInstanceLink (Variable "$word-inst-pred") parse)



(cog-execute! bl)

(cog-execute!
  (BindLink
    (And
      (PartOfSpeechLink
        (VariableNode "$word-instance-verb")
        (DefinedLinguisticConceptNode "verb"))
      (WordInstanceLink (VariableNode "$word-instance-verb") gparse))

    (VariableNode "$word-instance-verb")))
