
(use-modules
  (opencog)
  (opencog exec)
  (opencog nlp)
  (opencog nlp chatbot)
  (opencog nlp relex2logic)
  (opencog nlp sureal)
  ; (opencog pln)
  ; (opencog ure)
  (srfi srfi-1)
)

; (define (text-to-logic text)
;   text)

(define preparses
  (list
    ; "This is a test."
    "Are you stupified?"
    "happy"
    "Were you happy?"
    "Were you hungry?"

    "You are happy."
    "You were happy."

    "Do you eat candy?"
    "You eat candy?"
    "You wear jeans?"
    "Do you wear jeans?"
    "wear"
    "jeans"

    "He eats."
    "She eats quickly."
    "Nobody drank it."
    "It drinks water."

    "Did she drink water?"
    "Do you drink?"
    "You drink?"
    "You drank?"

  ))

(define logics (list
    ; (Evaluation (Predicate "happy") (List (Concept "you")))
    ; (Evaluation (Predicate "wear") (List (Concept "you")(Concept "jeans")))
    (Evaluation (Predicate "drink") (List (Concept "you")))
    (Evaluation (Predicate "drink") (List (Concept "you") (Concept "water")))

    ))

(display "Pre-parsing sureal sentences...\n")
(for-each (lambda (sentence) (nlp-parse sentence) ) preparses)

(define (sureal-for-logic logic)
  (define sureal-set
    (Set
      logic
      (Inheritance (InterpretationNode "blah")
                   (DefinedLinguisticConcept "TruthQuerySpeechAct"))
      (Inheritance (gar logic)
                   (DefinedLinguisticConceptNode "past"))
    )
  )
  (format #t "Sureal Set: ~a\n" sureal-set)
  (sureal sureal-set)
)

(display "calling sureal on logic statements...\n")
(define questions (map (lambda (logic) (sureal-for-logic logic)) logics))

questions
