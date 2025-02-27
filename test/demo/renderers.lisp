(in-package :forms.test)

(hunchentoot:define-easy-handler (demo-renderers :uri "/renderers") ()
  (flet ((render ()
           (forms:with-form-renderer :who
	     (who:with-html-output (forms.who:*html*)
	       (:h2 "CL-WHO")
	       (:p (who:str "Render via CL-WHO and whole form with RENDER-FORM."))
	       (forms:render-form (forms:find-form 'fields-form))
	       (:h2 "CL-WHO render by part")
	       (:p (who:str "Render via CL-WHO and the individual rendering functions RENDER-FORM-START, RENDER-FORM-END, RENDER-FIELD, RENDER-FIELD-LABEL and RENDER-FIELD-WIDGET."))
	       (forms:with-form (forms:find-form 'fields-form)
		 (forms:render-form-start)
		 (forms:render-field 'name)
		 (forms:render-field-label 'ready)
		 (forms:render-field-widget 'ready)
		 (forms:render-field 'sex)
		 (forms:render-field 'avatar)
		 (forms:render-field 'disabled)
		 (forms:render-field 'readonly)
		 (forms:render-field 'readonly-checkbox)
		 (forms:render-field 'disabled-checkbox)
		 (forms:render-field 'submit)
		 (forms:render-form-end))
	       (:h2 "Djula")
	       (:p (who:str "Render a form with a Djula template."))
	       (who:str (djula:render-template* (asdf:system-relative-pathname :cl-forms.demo "test/demo/djula-form.html") nil :form (find-form 'fields-form)))
	       (:h2 "Djula by part")
	       (:p (who:str "Render a form with a Djula template, by parts."))
	       (who:str (djula:render-template* (asdf:system-relative-pathname :cl-forms.demo "test/demo/djula-form-parts.html") nil :form (find-form 'fields-form)))
               ))))
    (render-demo-page :demo #'render
                      :source (asdf:system-relative-pathname :cl-forms.demo
                                                             "test/demo/renderers.lisp")
                      :active-menu :renderers)))


