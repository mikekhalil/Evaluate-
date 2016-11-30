/* Used nodeJS */

//globals
var expression;
var x;
var index = 0;
var tokens = [];
var curToken = null;
var validTokens = ["(", ")", "+", "-", "*",
 "/", "^", "cos", "sin", "tan", "ln", "atan", 
 "atan2", ","];

function getInput(s, callback) {
 process.stdin.resume();
 process.stdout.write(s);
 process.stdin.once('data', function(data) {
 	data = data.toString().trim();
    callback(data);
 });
}

getInput("Expression y=? ", function(e) {
  getInput("x=? ",  function(i) {
    	expression = e.toLowerCase().replace(" ", "");
    	x = parseFloat(i);
    	main();
    	process.exit();
  });
});

function Token(symbol, num) { 
	this.symbol = symbol;
	this.num = num;
}

function printTokens() {
	for(var i = 0; i < tokens.length; i++) console.log(tokens[i].symbol + " " + tokens[i].num);
}

function isToken(c) {
	for(var i = 0; i < validTokens.length; i++) 
		if (c == validTokens[i]) return true;
	return false;
}

function isNum(c) {
	if(!isNaN(parseInt(c))) return true;
	return false;
}

function getTokens() {
	var i = 0
	while (i < expression.length) {
		var c = expression.charAt(i);
		var foundToken = false;
		for(var j = 5; j >= 1; j--) {
			if (i < expression.length - j + 1){
				var ss = expression.substring(i,i+j+1)
				if(isToken(ss)) {
					foundToken = true;
					tokens.push(new Token(ss, 0));
					i += j + 1;
					break;
				}
			}
		}
		if (foundToken) continue;
		if (isToken(c)) tokens.push(new Token(c, 0));
		else if (c == "x") tokens.push(new Token(c, x));
		else if (isNum(c)) {
			var s = "";
			var count = 0;
			var ss = expression.substring(i, expression.length);
			for(var j = 0; j < ss.length; j++) { 
				char = ss.charAt(j);
				if (isNum(char)) {
					s += char;
					count++;
				}
				else break;
			}
			i += --count;
			tokens.push(new Token("int_const", parseFloat(s)));
		}
		
		
		i++;
	}
}

function hasNextToken() { 
	if (index < tokens.length) return true;
	return false;
}

function peekToken() { return tokens[index]; }

function consumeToken() { return tokens[index++]; }

function exprCondition() { 
	if (hasNextToken()) {
		if (peekToken().symbol == "+") return true;
		if (peekToken().symbol == "-") return true;
	}
	return false;
}

function termCondition() { 
	if (hasNextToken()) {
		if (peekToken().symbol == "*") return true;
		if (peekToken().symbol == "/") return true;
	}
	return false;
}
function exponentCondition() { 
	if (hasNextToken()) {
		if (peekToken().symbol == "^") return true;
	}
	return false;
}

function expr() { 
	var a = term();
	while(exprCondition()){ 
		var s = peekToken().symbol;
		curToken = consumeToken();
		var b = term();
		if( s == "+") a+= b;
		else a -= b;
	}
	return a;
}

function term() { 
	var a = exponent();
	while(termCondition()){ 
		var s = peekToken().symbol;
		curToken = consumeToken();
		var b = exponent();
		if( s == "*") a*= b;
		else a /= b;
	}
	return a;
}

function exponent() { 
	var a = factor();
	while(exponentCondition()){ 
		curToken = consumeToken();
		b = factor();
		a = Math.pow(a, b);
	}
	return a;
}

function factor() {
	if(!hasNextToken()) {
		throw new Error("Invalid expression");
	}

	curToken = consumeToken();
	if(curToken.symbol == "("){
		var a = expr();
		consumeToken(); //consume comma or rparent
		return a;
	}
	else if (curToken.symbol == "int_const" || curToken.symbol == "x") return curToken.num;
	else if (curToken.symbol == "sin") return Math.sin(factor());
	else if (curToken.symbol == "cos") return Math.cos(factor());
	else if (curToken.symbol == "tan") return Math.tan(factor());
	else if (curToken.symbol == "atan") return Math.atan(factor());
	else if (curToken.symbol == "atan2"){
		var a = factor();
		return Math.atan2(a,factor());
	}
	else if (curToken.symbol == "ln") return Math.log(factor());
	else { throw new Error("Invalid expression");}
}

function main() { 
	getTokens();
	curToken = peekToken();
	console.log(expr());
}