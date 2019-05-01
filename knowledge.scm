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
