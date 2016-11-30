import sys
import math

#global vars
index = 0 #index of token list
tokens = []
curToken = None

#get user input
def getExpression():
	expression = raw_input("Expression y=? ")
	return expression.lower()

def getX():
	try:
		x = float(input("x? "))
	except NameError:
		sys.exit("Invalid value for x")
	return x

#token class (symbol and numerical values)
class Token:
	def __init__(self,symbol, num):
		self.symbol = symbol
		self.num = num

#print tokens for debugging
def printTokens():
	for t in tokens:
		print t.symbol + " " + str(t.num)

#returns true if string is a valid Token
def isToken(c):
	validTokens = ["(", ")", "+", "-", "*", "/", "^", "cos", 
		"sin", "tan", "ln", "atan", "atan2", ","]
	if c in validTokens:
		return True
	return False

#returns true if string is a number
def isNum(c):
	try:
		float(c)
		return True
	except ValueError:
		return False


#convert expression into tokens
def getTokens(expression):
	global tokens, index, curToken
	i = 0
	while i < len(expression):
		c = expression[i]
		if c.isspace():
			i += 1
			continue
		if i < len(expression) - 4:
			subString = expression[i:i+5]
			if isToken(subString):
				tokens.append(Token(subString, 0))
				i += 5
				continue
		if i < len(expression) - 3:
			subString = expression[i:i+4]
			if isToken(subString):
				tokens.append(Token(subString,0))
				i += 4
				continue
		if i < len(expression)- 2:
			subString = expression[i:i+3]
			if isToken(subString):
				tokens.append(Token(subString,0))
				i += 3
				continue
		if i < len(expression)- 1:
			subString = expression[i:i+2]
			if isToken(subString):
				tokens.append(Token(subString,0))
				i += 2
				continue
		if isToken(c):
			tokens.append(Token(c, 0))
		elif c == "x":
			tokens.append(Token(c, x))
		elif isNum(c):
			s = ""
			count = 0
			subString = expression[i:]
			for char in subString:
				if isNum(char):
					s = s + char
					count += 1
				else:
					break	
			count -=1
			i += count
			tokens.append(Token("int_const", float(s)))
		else:
			return None
		i = i + 1 
	return tokens

#has another token to consume
def hasNextToken():
	global tokens, index, curToken
	if index < len(tokens):
		return True
	return False

#look at next token but doesnt consume it
def peekToken():
	global tokens, index, curToken
	if hasNextToken():
		return tokens[index]
	return None

#consumes token
def consumeToken():
	global tokens, index, curToken
	t = None
	if hasNextToken():
		t = tokens[index]
		index += 1
	return t

#condition for while loop in expr() function
def exprCondition():
	global tokens, index, curToken
	if hasNextToken():
		if peekToken().symbol == "+": return True
		if peekToken().symbol == "-": return True
	return False

#condition for while loop in term() function
def termCondition():
	global tokens, index, curToken
	if hasNextToken():
		if peekToken().symbol == "*": return True
		if peekToken().symbol == "/": return True
	return False

#condition for while loop in exponent() function
def exponentCondtion():
	global tokens, index, curToken
	if hasNextToken():
		if peekToken().symbol == "^": return True
	return False

#recursive decent evaluation
def expr():
	global tokens, index, curToken
	a = term()
	while (exprCondition()):
		s = peekToken().symbol
		curToken = consumeToken()
		b = term()
		if s == "+": a += b
		else: a -= b
	return a

def term():
	global tokens, index, curToken
	a = exponent()
	while(termCondition()):
		s = peekToken().symbol
		curToken = consumeToken()
		b = exponent()
		if s == "*": a *= b
		else: a /= b
	return a

def exponent():
	global tokens, index, curToken
	a = factor()
	while(exponentCondtion()):
		curToken = consumeToken()
		b = factor()
		a = a ** b
	return a

def factor():
	global tokens, index, curToken
	if not hasNextToken():
		sys.exit("Invalid Expression")

	curToken = consumeToken()
	if curToken.symbol == "(":
		a = expr()
		consumeToken() #consume RPARENT or comma
		return a
	elif curToken.symbol == "int_const":
		return curToken.num
	elif curToken.symbol == "sin":
		return math.sin(factor())
	elif curToken.symbol == "cos":
		return math.cos(factor())
	elif curToken.symbol == "tan":
		return math.tan(factor())
	elif curToken.symbol == "atan":
		return math.atan(factor())
	elif curToken.symbol == "atan2":
		a = factor()
		return math.atan2(a, expr())
	elif curToken.symbol == "ln":
		return math.log(factor())
	elif curToken.symbol == "x":
		return curToken.num
	else:
		sys.exit("Invalid Expression")

#main logic
expression = getExpression()
x = getX()
tokens = getTokens(expression)
if tokens == None:
	sys.exit("Invalid token(s)")
curToken = peekToken() #get first token
print expr()
