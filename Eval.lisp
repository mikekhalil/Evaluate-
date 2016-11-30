;globals
(setq expression nil)
(setq x nil)
(setq index 0)
(setq len 0) ; number of tokens
(setq tokens '())
(setq curToken nil)
(setq validTokens (list "(" ")" "+" "-" "*"
	"/" "^" "cos" "sin" "tan" "ln" "atan" 
	"atan2" ","))


; token structure 
(defstruct Token symbol num)

;gets input from user
(defun getInput()
	(princ "Expression y=? ")
	(setq expression (read-line))
	(princ "x=? ")
	(setq x (read-line))
	(setq x (read-from-string x))
)

; returns t if number, nil otherwise
(defun isNum(c)
	(setq temp (digit-char-p c ))
	(if(equalp nil temp) (return-from isNum nil))
	(return-from isNum t)
)
; returns t if token, otherwise, returns nil
(defun isToken(c)
	(loop 
		for vt in validTokens
  		do(
  			setq temp (string= c vt)
  		) 
      		(if(equalp t temp)(return-from isToken t))
  	)
	(return-from isToken nil)   
)

;prints tokens for debugging purposes
(defun printTokens()
	(loop
		for tkn in tokens 
		do (princ tkn)
		(terpri)
	)
)

(defun hasNextToken()
	(if(< index (list-length tokens))(return-from hasNextToken t))
	(return-from hasNextToken nil)
)

(defun peekToken()(return-from peekToken (nth index tokens)))
(defun consumeToken()
	(setq temp (nth index tokens))
	(setq index (+ index 1))
	(return-from consumeToken temp)
)

(defun exprCondition()
	(if (hasNextToken)
		(progn
			(if(string= (Token-symbol (peekToken)) "+")(return-from exprCondition t))
			(if(string= (Token-symbol (peekToken)) "-")(return-from exprCondition t))
		)
	)
	(return-from exprCondition nil)
)

(defun termCondition()
	(if (hasNextToken)
		(progn
			(if(string= (Token-symbol (peekToken)) "*")(return-from termCondition t))
			(if(string= (Token-symbol (peekToken)) "/")(return-from termCondition t))
		)
	)
	(return-from termCondition nil)
)

(defun exponentCondition()
	(if (hasNextToken)
		(progn
			(if(string= (Token-symbol (peekToken)) "^")(return-from exponentCondition t))
		)
	)
	(return-from exponentCondition nil)
)

(defun expr()
	(let ((a (term)))
	(loop while (exprCondition) do
		;(setq s (Token-symbol (peekToken)))
		(let ((s (Token-symbol (peekToken))))
		(setq curToken (consumeToken))
		(setq b (term))
		(if (string= s "+") 
			(setq a (+ a b))
			;else
		  	(setq a (- a b))
		))
	)
	(return-from expr a))
)

(defun term()
	(let ((termA (exponent)))
	(loop while (termCondition) do
		(let ((termS (Token-symbol (peekToken))))
		(setq curToken (consumeToken))
		(let ((termB (exponent)))
		(if (string= termS "*") 
			(setq termA (* termA termB))
			;else 
		  	(setq termA (/ termA termB))
			
		)))
	)
	(return-from term termA))
)
(defun exponent()
	(let ((expA (factor)))
	(loop while (exponentCondition) do
		(setq curToken (consumeToken))
		(setq expB (factor))
		(setq expA (expt expA expB))
	)

	(return-from exponent expA))
)
(defun factor()

	(setq curToken (consumeToken))

	(if (string= (Token-symbol curToken) "(")
		(progn
			(setq derpFace (expr))
			(consumeToken)
			(return-from factor derpFace)
		)
	)
	(if (string= (Token-symbol curToken) "int_const") (return-from factor (Token-num curToken)))
	(if (string= (Token-symbol curToken) "x") (return-from factor (Token-num curToken)))
	(if (string= (Token-symbol curToken) "sin") (return-from factor (sin (factor))))
	(if (string= (Token-symbol curToken) "cos") (return-from factor (cos (factor))))
	(if (string= (Token-symbol curToken) "tan") (return-from factor (tan (factor))))
	(if (string= (Token-symbol curToken) "atan") (return-from factor (atan (factor))))
	(if (string= (Token-symbol curToken) "ln") (return-from factor (log (factor))))
	(if (string= (Token-symbol curToken) "atan2")
			(progn
				(setq tempFactor (factor))
				(return-from factor (atan tempFactor (factor)))
			)
	)

)



(defun getTokens()
	(setq i 0)
	(loop while (< i (length expression)) do
		(setq c (char expression i))
		(setq foundToken nil)
		(setq j 5)
		(loop while (>= j 2) do
			(if (< i (+ 1 (- (length expression) j)))
				(progn
					(setq ss (subseq expression i (+ i j)))
					(if (isToken ss) 
						(progn
							(setq toke (make-Token :symbol ss :num 0))
							(setq tokens (cons toke tokens))
							(setq foundToken t)
							(setq len (+ len 1))
							(setq i (+ i j))
							(setq j -1) ; break loop
						)
					)
				)
			)
			(setq j (- j 1))
		)
			(if (equalp foundToken nil)
				(progn
					(if (isToken c)
						(progn
							(setq len (+ len 1))
							(setq toke (make-Token :symbol c :num 0))
							(setq tokens (cons toke tokens))
						)
					)
					(if(string=  c "x")
						(progn
							(setq len (+ len 1))
							(setq toke (make-Token :symbol c :num x))
							(setq tokens (cons toke tokens))
						)
					)
					(if(isNum c)
						(progn
							(setq s "")
							(setq count 0)
							(setq ss (subseq expression i (Length expression)))
							(setq j 0)
							(loop while (< j (Length ss)) do
								(setq tempChar (char ss j))
								(if (isNum tempChar)
									(progn
										(setq s (concatenate 'string s (list tempChar)))
										(setq count (+ count 1))
										(setq j (+ j 1))
									) 
								(setq j (Length ss))
								)
							)
						(setq i (- (+ i count) 1) )
						(setq toke (make-Token :symbol "int_const" :num (parse-integer s)))
						(setq tokens (cons toke tokens))
						)
					
					)
					(setq i (+ 1 i))
				)
			)
		)
)

;;main logic
(getInput)
(getTokens)
(setq tokens (reverse tokens))
(setq curToken (peekToken))
(princ (expr))

