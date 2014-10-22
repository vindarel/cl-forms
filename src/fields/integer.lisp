(in-package :forms)

(defclass integer-form-field (form-field)
  ()
  (:documentation "An integer input field"))

(defmethod validate-form-field ((form-field integer-form-field))
  (and
   (funcall (clavier:is-an-integer "~A is not an integer" (field-name form-field))
	    (field-value form-field))
   (call-next-method)))

(defmethod field-read-from-request ((field integer-form-field) form)
  (setf (field-value field)
	(and (hunchentoot:post-parameter (form-field-name field form))
	     (parse-integer (hunchentoot:post-parameter (form-field-name field form))
			    :junk-allowed t))))

(defmethod make-form-field ((field-type (eql :integer)) &rest args)
  (apply #'make-instance 'integer-form-field args))
