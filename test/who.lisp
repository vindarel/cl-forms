(defpackage :forms.test.who
  (:use :cl :forms))

(in-package :forms.test.who)

(hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 2021))

(forms:defform simple-form (:action "/simple-form/post")
  ((name :string :value "")
   (ready :boolean :value t)
   (sex :choice :choices (list "Male" "Female") :value "Male")
   (submit :submit :label "Create")))

(hunchentoot:define-easy-handler (simple-form :uri "/simple-form") ()
  (let ((form (forms::get-form 'simple-form)))
    (forms:with-form-renderer :who
      (forms:render-form form))))

(hunchentoot:define-easy-handler (simple-form-post :uri "/simple-form/post" :default-request-type :post) ()
  (let ((form (forms:get-form 'simple-form)))
    (forms::handle-request form)
    (forms::validate-form form)
    (forms::with-form-fields (name ready sex) form
      (who:with-html-output-to-string (html)
	(:ul 
	 (:li (who:fmt "Name: ~A" (forms::field-value name)))
	 (:li (who:fmt "Ready: ~A" (forms::field-value ready)))
	 (:li (who:fmt "Sex: ~A" (forms::field-value sex))))))))

(defclass person ()
  ((name :initarg :name
	 :accessor person-name
	 :initform nil)
   (single :initarg :single
	   :accessor person-single
	   :initform t)
   (sex :initarg :sex
	:accessor person-sex
	:initform :male)))

(forms:defform-builder model-form (person)
  (make-instance 'forms::form
		 :name 'model-form
		 :model person
		 :action "/model-form/post"
		 :fields (forms::make-form-fields
			  `((name :string :label "Name"
				  :accessor person-name)
			    (single :boolean :label "Single"
				    :accessor person-single)
			    (sex :choice :label "Sex"
				 :choices (:male :female)
				 :accessor person-sex
				 :formatter format-sex)
			    (submit :submit :label "Update")))))

(defun format-sex (sex)
  (if (equalp sex :male) "Male" "Female"))

(hunchentoot:define-easy-handler (model-form :uri "/model-form") ()
  (let ((person (make-instance 'person
			       :name "Foo"
			       :single t
			       :sex :male)))
    (let ((form (forms::get-form 'model-form person)))
      (forms:with-form-renderer :who
	(forms:render-form form)))))

(hunchentoot:define-easy-handler (model-form-post :uri "/model-form/post"
						  :default-request-type :post) ()
  (let ((person (make-instance 'person)))
    (let ((form (forms:get-form 'model-form person)))
      (forms::handle-request form)
      (forms::validate-form form)
      (who:with-html-output-to-string (html)
	(:ul 
	 (:li (who:fmt "Name: ~A" (person-name person)))
	 (:li (who:fmt "Single: ~A" (person-single person)))
	 (:li (who:fmt "Sex: ~A" (person-sex person))))))))

;; Choices widget test

(forms:defform choices-form (:action "/choices-form/post")
  ((sex :choice
	:choices (list "Male" "Female")
	:value "Male")
   (sex2 :choice
	 :choices (list "Male" "Female")
	 :value "Female"
	 :expanded t)
   (choices :choice
	    :choices (list "Foo" "Bar")
	    :value (list "Foo")
	    :multiple t)
   (choices2 :choice
	     :choices (list "Foo" "Bar")
	     :value (list "Bar")
	     :multiple t
	     :expanded  t)
   (submit :submit :label "Ok")))

(hunchentoot:define-easy-handler (choices-form :uri "/choices-form") ()
  (let ((form (forms::get-form 'choices-form)))
    (forms:with-form-renderer :who
      (forms:render-form form))))

(hunchentoot:define-easy-handler (choices-form-post :uri "/choices-form/post" :default-request-type :post) ()
  (let ((form (forms:get-form 'choices-form)))
    (forms::handle-request form)
    (forms::validate-form form)
    (forms::with-form-field-values (sex sex2 choices choices2) form
      (who:with-html-output-to-string (html)
	(:ul 
	 (:li (who:fmt "Sex: ~A" sex))
	 (:li (who:fmt "Sex2: ~A" sex2))
	 (:li (who:fmt "Choices: ~A" choices))
	 (:li (who:fmt "Choices2: ~A" choices2)))))))

(forms:defform validated-form (:action "/validated-form/post")
  ((name :string :value "" :constraints (list (clavier:is-a-string)
					      (clavier:not-blank)
					      (clavier:len :max 5)))
   (ready :boolean :value t)
   (sex :choice :choices (list "Male" "Female") :value "Male")
   (submit :submit :label "Create")))

(let ((form (forms:get-form 'validated-form)))
  (setf (forms::field-value (forms::get-field form 'name))
	"lala")
  (forms::validate-form form)
  (setf (forms::field-value (forms::get-field form 'name))
	"")
  (setf (forms::field-value (forms::get-field form 'name))
	"asdfasdf")
  (forms::validate-form form)
  (setf (forms::field-value (forms::get-field form 'ready))
	"foo")
  (forms::validate-form form)
  (forms::form-errors form))

(hunchentoot:define-easy-handler (validated-form :uri "/validated-form") ()
  (let ((form (forms::get-form 'validated-form)))
    (forms:with-form-renderer :who
      (forms:render-form form))))

(hunchentoot:define-easy-handler (validated-form-post :uri "/validated-form/post" :default-request-type :post) ()
  (let ((form (forms:get-form 'validated-form)))
    (forms::handle-request form)
    (if (forms::validate-form form)
	;; The form is valid
	(forms::with-form-fields (name ready sex) form
	  (who:with-html-output-to-string (html)
	    (:ul 
	     (:li (who:fmt "Name: ~A" (forms::field-value name)))
	     (:li (who:fmt "Ready: ~A" (forms::field-value ready)))
	     (:li (who:fmt "Sex: ~A" (forms::field-value sex))))))
	;; The form is not valid
	(forms:with-form-renderer :who
	  (forms:render-form form)))))
