; Proof of concept question posing in response to utterance based on background
; knowledge and reasoning
; qp-parse.scm explores different parsing and representation approaches

(use-modules
	(opencog)
	(opencog exec)
	(opencog nlp)
	(opencog nlp chatbot)
	(opencog nlp relex2logic)
	(opencog nlp sureal)
	(srfi srfi-1) ; needed for delete-duplicates
)

; -----------------------------------------------------------------------
(define (parse-get-relex-relation-type parse rel-type)
; Get the relex relations of a given relationship type
; Todo: handle muliple relations of the same type
  (define gl
    (GetLink
      ; Defining type here to avoid returning VariableNodes
      (VariableList
        (TypedVariableLink
          (VariableNode "$word-inst-head")
          (TypeNode "WordInstanceNode"))
        (TypedVariableLink
          (VariableNode "$word-inst-dependent")
          (TypeNode "WordInstanceNode")))
      (And
        (Evaluation
          (DefinedLinguisticRelationshipNode rel-type)
          (List (Variable "$word-inst-head") (Variable "$word-inst-dependent")))
        (WordInstanceLink (Variable "$word-inst-head") parse)
        (WordInstanceLink (Variable "$word-inst-dependent") parse)
      )
    )
  )
  (gar (cog-execute! gl))
)

(define (parse-get-obj-relation parse)
  (parse-get-relex-relation-type parse "_obj"))


(define (parse-get-subj-relation parse)
  (parse-get-relex-relation-type parse "_subj"))


; Replaced by above (parse-get-obj-relation)
#!
(define (parse-get-verb-obj parse)
  (define bl
    (BindLink
      (And
        (Evaluation
          (DefinedLinguisticRelationshipNode "_obj")
          (List (Variable "$word-inst-verb") (Variable "$word-inst-obj")))
        (WordInstanceLink (Variable "$word-inst-verb") parse)
        (WordInstanceLink (Variable "$word-inst-obj") parse)
      )
      (List (Variable "$word-inst-pred") (Variable "$word-inst-obj"))
    )
  )
 (gar (cog-execute! bl))
)
!#

(define (parse-get-obj parse)
	(let ((verb-obj (parse-get-obj-relation parse)))
	  (if (null? verb-obj)
	    '()
	    (gdr verb-obj))))

(define (parse-get-verbs parse)
 (cog-execute!
   (BindLink
     (And
       (PartOfSpeechLink
         (VariableNode "$word-instance-verb")
         (DefinedLinguisticConceptNode "verb"))
       (WordInstanceLink (VariableNode "$word-instance-verb") parse))
     (VariableNode "$word-instance-verb"))))

; Todo: Handle multiple verbs
(define (parse-get-verb-word parse)
  (word-inst-get-lemma
    (gar
      (parse-get-verbs parse))))
;      (cog-execute!
;        (BindLink
;          (And
;            (PartOfSpeechLink
;              (VariableNode "$word-instance-verb")
;              (DefinedLinguisticConceptNode "verb"))
;            (WordInstanceLink (VariableNode "$word-instance-verb") parse))
;          (VariableNode "$word-instance-verb"))))))

(define (parse-get-relex-relation-words parse)
 ; Not sure whether we should use Words or Lemmas here
 ; Using lemmas
  (delete '()
    (map word-inst-get-lemma
      (map relation-get-dependent (parse-get-relex-relations parse))
    )
  )
)

(define (parse-get-key-words parse)
  (map cog-name
     (delete '()
      (delete-duplicates
        (append
          (list (parse-get-verb-word parse))
          (parse-get-relex-relation-words parse)
        )
      )
    )
  )
)

; -----------------------------------------------------------------------
; Utilities

; Get the WordNode for the given WordInstance
(define (word-inst-get-word instance)
  (car (cog-chase-link 'ReferenceLink 'WordNode instance)))

; Use word-inst-get-lemma in relex-utils.scm instead
; Get the lemma for a given WordInstance
(define (instance-get-lemma instance)
  (car (cog-chase-link 'LemmaLink 'WordNode instance)))


; Temp define top level global vars to use for easier debugging
(define gsent)
(define gparse)
(define gsent)
(define gabstract)
(define grelex)
(define grelations)
(define gr2l)
(define gverbs)
(define gverb)
(define gsubj-rel)
(define gobj-rel)
(define gobj)
(define gpobj-rel)
(define gkey-words)

; -----------------------------------------------------------------------
(define (qp-parse text)

  ; Todo: Handle multiple sentences? Not sure if parser returns multiples.
  (define sent (car (nlp-parse text)))

  ; For now we are just using the first parse
  ; Todo: Use multiple parses, if parser returns multiple
  (define parse (car (sentence-get-parses sent)))

  ; use just the first one for now
  (define interp (car (sent-get-interp sent)))

  (define abstract (get-abstract-version interp))

  (define relex (parse-get-relex-outputs parse))
  ; relex

  (define relations (parse-get-relex-relations parse))

  (define r2l (sent-get-r2l-outputs sent))
  ;r2l

  (define verbs (parse-get-verbs parse))
  (define verb (parse-get-verb-word parse))

  (define subj-rel (parse-get-subj-relation parse))

  (define obj-rel (parse-get-obj-relation parse))

  (define obj (parse-get-obj parse))

  (define pobj-rel (parse-get-relex-relation-type parse "_pobj"))

  ; Todo: add iobj

  (define key-words (parse-get-key-words parse))

  ; Temp for debugging
  (set! gsent sent)
  (set! gparse parse)
  (set! grelex relex)
  (set! grelations relations)
  (set! gabstract abstract)
  (set! gr2l r2l)
  (set! gverbs verbs)
  (set! gverb verb)
  (set! gsubj-rel subj-rel)
  (set! gobj-rel obj-rel)
  (set! gobj obj)
  (set! gpobj-rel pobj-rel)
  (set! gkey-words key-words)

  ; subj-rel
  ; key-words
  (display "\n------------------------------------------\n")
  (display "r2l:\n\n")
  (display r2l)
  (display "\n\n------------------------------------------\n")
  (display "\nabstract version:\n\n")
  (display abstract)
)


;;;;;;;;;;;;;;;;
; Utils

(define p qp-parse)

(define (e-parse text)
 (define sent (car (nlp-parse text)))
  ; For now we are just using the first parse
  ; Todo: Use multiple parses, if parser returns multiple
  (define parse (car (sentence-get-parses sent)))
  parse
)

(define ep e-parse)


; Todo: How to deal with sentences with multiple subj-verb-obj triplets. E.g.,
; "Do you want to eat ice cream."
; Todo: Add nn DefinedLigusticConcept, as in for "ice cream"


