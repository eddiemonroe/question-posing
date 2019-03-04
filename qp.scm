; Proof of concept question posing in response to utterance based on background
; knowledge and reasoning

(use-modules
	(opencog)
	(opencog exec)
	(opencog nlp)
	(opencog nlp chatbot)
	(opencog nlp relex2logic)
	(opencog nlp sureal)
)

(define (parse-get-verb-obj parse)
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
 (gar (cog-execute! bl))
)

(define (parse-get-obj parse)
  (gdr (parse-get-verb-obj parse)))

(define (parse-get-verb parse)
  (gar
    (cog-execute!
      (BindLink
        (And
          (PartOfSpeechLink
            (VariableNode "$word-instance-verb")
            (DefinedLinguisticConceptNode "verb"))
          (WordInstanceLink (VariableNode "$word-instance-verb") parse))
        (VariableNode "$word-instance-verb")))))



; Utilities

; Get the WordNode for the given WordInstance
(define (instance-get-word instance)
  (car (cog-chase-link 'ReferenceLink 'WordNode instance)))

; Get the lemma for a given WordInstance
(define (instance-get-lemma instance)
  (car (cog-chase-link 'LemmaLink 'WordNode instance)))


; Temp define top level global vars to use for easier debugging
(define gsent)
(define gparse)
(define grelex)
(define gr2l)
(define gverb-obj)
(define gobj)

(define (qp text)

  ; Todo: Handle multiple sentences? Not sure if parser returns multiples.
  (define sent (car (nlp-parse text)))

  ; For now we are just using the first parse
  ; Todo: Use multipe parses, if parser returns multiple
  (define parse (car (sentence-get-parses sent)))

  (define relex (parse-get-relex-outputs parse))
  ; relex

  (define r2l (sent-get-r2l-outputs sent))
  ;r2l
 
  (define verb-obj (parse-get-verb-obj parse))

  (define obj (parse-get-obj parse))
  ; parse-obj

 ; Temp for debugging
 (set! gsent sent)
 (set! gparse parse)
 (set! grelex relex)
 (set! gr2l r2l)
 (set! gverb-obj verb-obj)
 (set! gobj obj)
 
 parse-obj

)


Todo: How to deal with sentences with multiple subj-verb-obj triplets. E.g., "Do
you want to eat ice cream."



