program Eval;

Uses sysutils, strutils, Math;
type Token = Object
	var symbol : string;
	var num : double;
end;
type stringlist = array[0..100] of ansistring;
type tokenlist = array[0..100] of Token;
var expression : ansistring;	//expression from user
var x : double; 				//value of x input by user
var index : integer = 0; 		//curent index
var len : integer = 0; 			//number of tokens
var tokens : tokenlist;			//tokens
var curToken : Token;
var validTokens : stringlist;


procedure init();
begin
	validTokens[0] := '(';
	validTokens[1] := ')';
	validTokens[2] := '+';
	validTokens[3] := '-';
	validTokens[4] := '*';
	validTokens[5] := '/';
	validTokens[6] := '^';
	validTokens[7] := 'cos';
	validTokens[8] := 'sin';
	validTokens[9] := 'tan';
	validTokens[10] := 'ln';
	validTokens[11] := 'atan';
	validTokens[12] := 'atan2';
	validTokens[13] := ',';
end;

procedure getInput();
begin
  write ('Expression y=? ');
  readln(expression);
  expression := DelSpace(expression);
  write('x=? ');
  readln(x);
end;

procedure printTokens();
var i : integer;
begin
	for i := 0 to len-1 do
	begin
		write(tokens[i].symbol +  ' ');
		write(tokens[i].num);
		writeln();

	end
end;

function isToken(c : ansistring): boolean;
var counter : integer;
var same : integer;
begin
	for counter:= 0 to 13 do 
	begin
		same := AnsiCompareStr(c,validTokens[counter]);
		if same = 0 then
			Exit(true);
	end;
	isToken := false;
end;

function isNum(c : ansistring): boolean;
var v : integer;
var code : integer;
begin
	Val(c,v,code);
	if code > 0 then
		Exit(false);

	Exit(true);
end;

function hasNextToken(): boolean;
begin
	if index < len then
		Exit(true);
	Exit(false);
end;

function peekToken(): Token;
begin 
	Exit(tokens[index]);
end;

function consumeToken(): Token;
begin
	index := index + 1;
	Exit(tokens[index-1]);
end;

function exprcondition(): boolean;
var same : integer = 1;
begin
	if hasNextToken() then
	begin
		same := AnsiCompareStr(peekToken().symbol, '+');
		if same = 0 then
			Exit(true);
		same := AnsiCompareStr(peekToken().symbol, '-');
		if same = 0 then
			Exit(true);
	end;
	Exit(false);
end;

function termCondition(): boolean;
var same : integer = 1;
begin
	if hasNextToken() then
	begin
		same := AnsiCompareStr(peekToken().symbol, '*');
		if same = 0 then
			Exit(true);
		same := AnsiCompareStr(peekToken().symbol, '/');
		if same = 0 then
			Exit(true);
	end;
	Exit(false);
end;

function exponentCondition(): boolean;
var same : integer = 1;
begin
	if hasNextToken() then
	begin
		same := AnsiCompareStr(peekToken().symbol, '^');
		if same = 0 then
			Exit(true);
	end;
	Exit(false);
end;

function expr(): double;
	function factor(): double;
	var a : double;
	begin
		curToken := consumeToken();
		if AnsiCompareStr(curToken.symbol, '(') = 0 then
		begin
			a := expr();
			consumeToken();
			Exit(a);
		end;
		if AnsiCompareStr(curToken.symbol, 'int_const') = 0 then
			Exit(curToken.num);
		if AnsiCompareStr(curToken.symbol, 'sin') = 0 then
			Exit(sin(factor()));
		if AnsiCompareStr(curToken.symbol, 'cos') = 0 then
			Exit(cos(factor()));
		if AnsiCompareStr(curToken.symbol, 'tan') = 0 then
			Exit(tan(factor()));
		if AnsiCompareStr(curToken.symbol, 'atan') = 0 then
			Exit(arctan(factor()));
		if AnsiCompareStr(curToken.symbol, 'atan2') = 0 then
			begin
				a := factor();
				Exit(arctan2(a,factor()));
			end;
		if AnsiCompareStr(curToken.symbol, 'ln') = 0 then
			Exit(ln(factor()));
		if AnsiCompareStr(curToken.symbol, 'x') = 0 then
			Exit(curToken.num);
	

	end;
	function exponent(): double;
		var a : double;
		var b : double;
		var s : ansistring;
		begin
			a := factor();
			while exponentCondition() do 
			begin
				s := peekToken().symbol;
				curToken := consumeToken();
				b := factor();
				a := power(a,b);
			end;
			Exit(a);
	end;
	function term(): double;
	var a : double;
	var b : double;
	var s : ansistring;
	begin
		a := exponent();
		while termCondition() do 
		begin
			s := peekToken().symbol;
			curToken := consumeToken();
			b := exponent();
			if AnsiCompareStr(s,'*') = 0 then
				a := a * b
			else
				a := a / b
		end;
		Exit(a);
	end;

var a : double;
var b : double;
var s : ansistring;
begin
	a := term();
	while exprCondition() do 
	begin
		s := peekToken().symbol;
		curToken := consumeToken();
		b := term();
		if AnsiCompareStr(s,'+') = 0 then
			a := a + b
		else
			a := a - b
	end;
	Exit(a);
end;


procedure getTokens();
var i : integer = 1;
var j : integer = 0;
var c : ansistring;
var foundToken : boolean;
var ss : ansistring;
var s : ansistring;
var count : integer;
var newToken : Token;
var char : ansistring;
var v : integer;
var code : integer;
begin
	while(i <= Length(expression)) do
	begin

		c := expression[i];
		foundToken := false;
		for j:= 5 downto 1 do
		begin
			if i < Length(expression) - j + 1 then
			begin
				ss := copy(expression, i, j + 1);
				if isToken(ss) then
				begin
					foundToken := true;
					newToken.symbol := ss;
					newToken.num := 0;;
					tokens[len] := newToken;
					len := len + 1;
					i := i + j + 1;
					Break
				end
			end		
		end;
		if foundToken then Continue;
		if isToken(c) then
		begin
			newToken.symbol := c;
			newToken.num := 0;
			tokens[len] := newToken;
			len := len + 1
		end
		else if AnsiCompareStr(c,'x') = 0 then
		begin
			newToken.num := x;
			newToken.symbol	:= c;
			tokens[len] := newToken;
			len := len + 1
		end
		else if isNum(c) then
		begin
			s := '';
			count := 0;
			ss := copy(expression, i, Length(expression));
			for j := 1 to Length(ss) do
			begin
				char := ss[j];
				if isNum(char) then
				begin 
					s := s + char;
					count := count + 1
				end
				else break
			end;
			i := i + count - 1;
			newToken.symbol := 'int_const';
			val(s,v,code);
			newToken.num := v;
			tokens[len] := newToken;
			len := len + 1;
		end;
		i := i + 1;
	end
end;

(* Main *)
begin
	init();
  	getInput();
  	getTokens();
  	curToken := peekToken();
  	writeln(FloatToStr(expr()));
end.

