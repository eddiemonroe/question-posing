;; Background knowledge for question posing proof of concept

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
      (Predicate "relax"))))

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
    (Variable "$PersonX")))

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
        (Predicate "eat")
        (List
          (Variable "$PersonX")
          (Concept "popcorn"))))

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
    (Predicate "amused")
    (Variable "$PersonX")))


;; Test
(ImplicationScope (stv 1 1)
  (TypedVariable
    (Variable "$A")
    (Type "ConceptNode"))
  (Evaluation
    (Predicate "implicant")
    (list
      (Variable "$A")))
  (Evaluation
    (Predicate "implicand")
    (List
      (Variable "$A"))))


  (ImplicationScope (stv 1 1)
    (TypedVariable
      (Variable "$PersonX")
      (Type "ConceptNode"))
    (Evaluation
      (Predicate "drink")
      (List
        (Variable "$PersonX")
        (Concept "beer")))
    (Evaluation
      (Predicate "drunk")
      (List
        (Variable "$PersonX"))))
