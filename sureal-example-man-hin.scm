; Load the modules, for nlp-parse and sureal
(use-modules
  (opencog)
  (opencog nlp)
  (opencog nlp chatbot)
  (opencog nlp relex2logic)
  (opencog nlp sureal)
)

; ---------- Setup ---------- ;
; Set the address for relex server, might not need but it doesn't hurt
(set-relex-server-host)

; First of all, parse a sentence so that we can generate sentences with the exact same syntactic structure
(nlp-parse "is that the cat?")

; Let's say someone says "I got into a fight with my wife", and after doing some PLN magic we want to
; ask something that involves "jealousy" and "course", then we wrap it up in some logical representation:
(define sss
  (Set
    ; The main stuff we want to say
    (Evaluation
      (Predicate "was")
      (List
        (Concept "jealousy")
        (Concept "cause")))
    ; This one is to constraint SuReal to generate a yes/no question
    (Inheritance
      (InterpretationNode "sureal-doesnt-care-this-one")
      (DefinedLinguisticConcept "TruthQuerySpeechAct"))
))

; BUT, before sending it to SuReal, we have to make sure all the words,
; i.e. "jealousy", "was", and "course" in this case, are there already
; in the AtomSpace and in the correct form and tense. Otherwise SuReal
; doesn't know what to do. This is the reason why we need to pre-parse
; a lot of sentences just to hope that we have all the (common) words
; that we care in different forms and tenses etc.
; For this example, I just make up two sentences for that purpose:
(nlp-parse "jealousy is a disease")  ; -- for "jealousy"
;(nlp-parse "that was the best course of action")  ; -- for "was" and "course"
(nlp-parse "texting was the cause of the accident")  ; -- for "was" and "cause"

; Finally send to SuReal, should generate ("was" "jealousy" "the" "course" "?")
(sureal sss)

