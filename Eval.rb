
#globals
$index = 0
$tokens = Array.new
$curToken = nil

#get input
def getX()
	print("x? ")
	x = gets.to_f
end

def getExpression()
	print("Expression y=? ")
	expression = gets 
end

class Token
	def initialize(symbol,num)
		@symbol = symbol
		@num = num
	end
	def num
		@num
	end
	def symbol
		@symbol
	end
	def display
		puts "#{@symbol} #{@num}"
	end
end

#print tokens for debugging
def printTokens()
		$tokens.each { |t| t.display } 
end

#returns true if token
def isToken(c)
	validTokens = ["(", ")", "+", "-", "*",
	 "/", "^", "cos", "sin", "tan", "ln", "atan", 
	 "atan2", ","].include?(c)
end

#returns true if number
def isNum(c)
	Integer(c) rescue return false
	return true
end

#convert expression into tokens
def getTokens(expression, x)
	i = 0
	while i < expression.length-1 do 
		c = expression[i]
		foundToken = false
		for j in (4).downto(1)
			if i < expression.length - j
				subString = expression[i..i+j]
				if isToken(subString) 
					$tokens.push(Token.new(subString, 0))
					i += j+1
					foundToken = true
					break	
				end
			end
		end
		foundToken ? next : 0
		if isToken(c)
			$tokens.push(Token.new(c, 0))
		elsif c == "x"
			$tokens.push(Token.new(c, x))
		elsif isNum(c)
			s = String.new
			count = 0
			subString = expression[i..expression.length-1]
			subString.split("").each do |char|
				if isNum(char)
					s << (char)
					count += 1
				else 
					break
				end
			end
			count -= 1
			i += count
			$tokens.push(Token.new("int_const", s.to_f))
		else 
			abort("Invalid Token(s)")
		end
		i += 1
	end 
end

#helper functions
def hasNextToken()
	if $index < $tokens.length
		return true
	end
	return false
end

def peekToken()
	return $tokens[$index]
end

def consumeToken()
	t = $tokens[$index]
	$index += 1
	return t
end

def exprCondition()
	if hasNextToken()
		if peekToken().symbol == "+"
			return true
		end
		if peekToken().symbol == "-"
			return true
		end
	end
	return false
end

def termCondition()
	if hasNextToken()
		if peekToken().symbol == "/"
			return true
		end
		if peekToken().symbol == "*"
			return true
		end
	end
end

def exponentCondition()
	if hasNextToken()
		if peekToken().symbol == "^"
			return true
		end
	end
end

def expr()
	a = term()
	while(exprCondition()) do
		s = peekToken().symbol
		$curToken = consumeToken()
		b = term()
		if s == "+" 
			a += b
		else 
			a -= b
		end 
	end
	return a
end

def term()
	a = exponent()
	while (termCondition()) do
		s = peekToken().symbol
		$curToken = consumeToken()
		b = exponent()
		if s == "*"
			a *= b
		else
			a /= b
		end
	end
	return a
end
def exponent()
	a = factor()
	while (exponentCondition()) do
		s = peekToken().symbol
		$curToken = consumeToken()
		b = factor()
		a = a ** b
	end
	return a
end

def factor()
	if not(hasNextToken())
		abort("Invalid Expression")
	end

	$curToken = consumeToken()
	if $curToken.symbol == "("
		a = expr()
		consumeToken()
		return a
	elsif $curToken.symbol == "int_const"
		return $curToken.num
	elsif $curToken.symbol == "sin"
		 return Math.sin(factor())
	elsif $curToken.symbol == "cos"
		 return Math.cos(factor())
	elsif $curToken.symbol == "tan"
		return Math.tan(factor())
	elsif $curToken.symbol == "atan"
		return Math.atan(factor())
	elsif $curToken.symbol == "atan2"
		a = factor()
		return Math.atan2(a, expr())
	elsif $curToken.symbol == "ln"
		return Math.log(factor())
	elsif $curToken.symbol == "x"
		return $curToken.num
	else
		abort("Invalid Expression")
	end
end
#main logic
expression = getExpression().delete(' ').downcase
x = getX()
getTokens(expression, x)
$curToken = peekToken()
puts expr()


