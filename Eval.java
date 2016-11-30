import java.util.*;

public class Eval {
	//Global Variables
	static double x; 											//input value from user
	static double y = 0; 										//output value
	static int index = 0; 										//index for lexical anyalsis
	static String expression;									//the expression input by user
	static ArrayList<Token> tokens = new ArrayList<Token>(); 	//All of the tokens from the expression
	static Token curToken = null;
	static Boolean validExpression = true; 

	public static void main(String[] args) { 
		getInput();
		if(!lex()) { //invalid characters
			System.out.println("Invalid token(s)");
			return;
		}
		curToken = peekToken();
		y = expr();
		if(validExpression) System.out.println(y);
		else System.out.println("Invalid expression");
	}

	//recursive descent evaluation
	public static double expr() {	
		double a = 0,b = 0,c = 0;
		a = term();
		while(hasNextToken() && (peekToken().symbol == Symbol.PLUS ||
				peekToken().symbol == Symbol.MINUS)) {
			Symbol s = peekToken().symbol;
			if(s == Symbol.PLUS) {
				curToken = consumeToken();
				b = term();
				a += b;
			}
			else if(s == Symbol.MINUS) {
				curToken = consumeToken();
				b = term();
				a -= b;
			}
		}

		return a;
	}

	public static double term() { 
		double a = 0, b = 0, c = 0;
		a = exponent();
		while(hasNextToken() && (peekToken().symbol == Symbol.MULTIPLY ||
				peekToken().symbol == Symbol.DIVIDE)) {
			if(peekToken().symbol == Symbol.MULTIPLY) {
				curToken = consumeToken();
				b = exponent();
				a *= b;
			}
			else if(peekToken().symbol == Symbol.DIVIDE) {
				curToken = consumeToken();
				b = exponent();
				a /= b;
			}
		}
		return a;
	}

	public static double exponent() {
		double a = 0, b = 0, c = 0;
		a = factor();
		while(hasNextToken() && (peekToken().symbol == Symbol.EXPONENT)) {
			curToken = consumeToken();
			b = factor();
			a = Math.pow(a,b);
		}
		return a;
	}

	public static double factor() { 
		if(!hasNextToken()) {
			//invalid expression
			validExpression = false;
			return -1;
		}

		curToken = consumeToken();
		if(curToken.symbol == Symbol.LPARENT) {
			double tempExp = expr();
			curToken = consumeToken(); //consume RPARENT or comma
			return tempExp;
		}
		else if(curToken.symbol == Symbol.INT_CONST) {
			return Double.parseDouble(curToken.int_const);
		}
		else if(curToken.symbol == Symbol.SIN) { 
			return Math.sin(factor());
		}
		else if(curToken.symbol == Symbol.COS) { 
			return Math.cos(factor());
		}
		else if(curToken.symbol == Symbol.TAN) { 
			return Math.tan(factor());
		}
		else if(curToken.symbol == Symbol.ATAN) { 
			return Math.atan(factor());
		}
		else if(curToken.symbol == Symbol.ATAN2) { 
			double a;
			a = expr();
			return Math.atan2(a, expr());
		}
		else if(curToken.symbol == Symbol.LN) { 
			return Math.log(factor());
		}
		else if(curToken.symbol == Symbol.X) {
			return x;
		}
		validExpression = false;
		return -1;
	}

	//get input from user
	public static void getInput() {
		System.out.print("Expression y=? ");
		Scanner s = new Scanner(System.in);
		expression = s.nextLine();
		expression.toLowerCase();
		System.out.print("x? ");
		x = s.nextDouble();
	}

	//Lexical Analysis  
	public static enum Symbol {
		X, PLUS, MINUS, MULTIPLY, DIVIDE, EXPONENT, LPARENT, RPARENT, SIN, COS, TAN, LN, ATAN, ATAN2, INT_CONST, COMMA;
	}
	
	public static class Token {
		//either an int or a symbol
		public Symbol symbol; //enum symbol
		public String int_const; //int const
		
		//constructors
		public Token(Symbol symbol) {
			this.symbol = symbol;
			this.int_const = null;
		}

		public Token(Symbol symbol, String int_const) {
			this.symbol = symbol;
			this.int_const = int_const;
		}
	}

	public static boolean  lex() { 
		for(int i = 0; i < expression.length(); i++) { 
			char c = expression.charAt(i); 
			Token token = null;
			boolean ws = false; 
			if(Character.isWhitespace(c)) ws = true; //consume and ignore whitespace
			else if (c == '(') token = new Token(Symbol.LPARENT);
			else if (c == ')') token = new Token(Symbol.RPARENT);
			else if (c == 'x') token = new Token(Symbol.X);
			else if (c == '+') token = new Token(Symbol.PLUS);
			else if (c == '-') token = new Token(Symbol.MINUS);
			else if (c == '*') token = new Token(Symbol.MULTIPLY);
			else if (c == '/') token = new Token(Symbol.DIVIDE);
			else if (c == '^') token = new Token(Symbol.EXPONENT);
			else if (c == ',') token = new Token(Symbol.COMMA);
			else if (c == 's' && i + 2 < expression.length()){ 
				String sin = expression.substring(i,i+3);
				i += 2;
				if(sin.equals("sin")) token = new Token(Symbol.SIN);
				else return false;
			}
			else if (c == 'c' && i + 2 < expression.length()) {
				String cos = expression.substring(i,i+3);
				i += 2;
				if(cos.equals("cos")) token = new Token(Symbol.COS);
				else return false;
			}
			else if (c == 't' && i + 2 < expression.length()) {
				String tan = expression.substring(i,i+3);
				i += 2;
				if(tan.equals("tan")) token = new Token(Symbol.TAN);
				else return false;
			}
			else if (c == 'l' && i + 1 < expression.length()) {
				String ln = expression.substring(i,i+2);
				i += 1;
				if(ln.equals("ln")) token = new Token(Symbol.LN);
				else return false;
			}
			else if (c == 'a' && i + 3 < expression.length()) {
				//either atan or atan2, requires lookAhead
				if(i + 4 < expression.length()) {
					String atan2 = expression.substring(i,i+5);
					i += 4;
					if(atan2.equals("atan2")) token = new Token(Symbol.ATAN2);
					else i -= 4;
				}
				if(token == null) { //wasnt atan2
					String atan = expression.substring(i, i+4);
					i += 3;
					if(atan.equals("atan")) token = new Token(Symbol.ATAN);
					else return false;
				}
			}
			else if(isInt(c)) {
				String int_const = new String();
				while(i < expression.length() && isInt(expression.charAt(i))){
					int_const += String.valueOf(expression.charAt(i));
					i++;
				}
				i--;
				token = new Token(Symbol.INT_CONST, int_const);
			}
			else {
				//invalid character
				return false;
			}
			if(!ws)tokens.add(token);
		}
		return true;
	}
	//check to see if character is an int
	public static boolean isInt(char c) {
		if(c >= '0' && c <= '9') return true;
		return false;
	}
	//check to see if there is a next token
	public static boolean hasNextToken() {
		if(index < tokens.size()) return true;
		return false;
	}
	//consume token
	public static Token consumeToken() {
		if(index < tokens.size()){ 
			return tokens.get(index++);
		}
		return null;
	}
	//peek at token, don't consume it
	public static Token peekToken() {
		if(index < tokens.size()) return tokens.get(index);
		return null;
	}
	//help for debugging
	public static void printTokens() {
		for(int i = 0; i < tokens.size(); i++) {
			Token t = tokens.get(i);
			System.out.print(t.symbol);
			if(t.symbol == Symbol.INT_CONST) System.out.print(" " + t.int_const);
			System.out.println();
		}
	}
}