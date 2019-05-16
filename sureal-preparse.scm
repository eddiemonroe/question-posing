;Pre-parsed sentences for Sureal

(nlp-parse "Were you interested?")
; (nlp-parse "I am entertained")
; (nlp-parse "I wanted to relax")

;(nlp-parse "I was amused.")
;(nlp-parse "The dog was amused.")
(nlp-parse "amused")
(nlp-parse "entertained")

(nlp-parse "Did you want to swim?")
; Looks the "to" in "to relax" is needed to get "Did you want to relax?"
(nlp-parse "to relax")
; (nlp-parse "You wanted to relax?")
; (nlp-parse "You want to relax?")
; (nlp-parse "You were wanting to relax.")

(nlp-parse "Did he eat fish?")
(nlp-parse "popcorn")
