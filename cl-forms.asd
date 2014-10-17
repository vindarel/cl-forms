;;;; cl-forms.asd

(asdf:defsystem #:cl-forms
  :serial t
  :description "Describe cl-forms here"
  :author "Mariano Montone"
  :license "MIT"
  :depends-on (#:alexandria
               #:cl-ppcre
               #:hunchentoot
	       #:clavier)
  :components ((:module :src
			:components
			((:file "package")
			 (:file "cl-forms")
			 (:module :fields
				  :components
				  ((:file "string")
				   (:file "boolean")
				   (:file "choice")
				   (:file "submit")))))))
	       
