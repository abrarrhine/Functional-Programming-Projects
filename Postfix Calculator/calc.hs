-- Token: class definition for a single token.
data Token = Num Double | Op String | Err String
instance Show Token where
  show (Num n)   = (show n)
  show (Op op)   = op
  show (Err err) = err

-- Return the string of the operator token
-- USAGE: opStr op
opStr :: Token -> String
opStr (Op o) = o

isOperator :: String -> Bool
isOperator str
           | str == "+"     || str == "*"    ||
             str == "-"     || str == "/"       = True
           | otherwise                          = False

isNumber :: String -> Bool
isNumber str = if ((not (null (reads str :: [(Double,String)]))) &&
                  ((snd (head (reads str :: [(Double,String)])))==""))
               then True
               else False

strToDouble :: String -> Double
strToDouble str = fst (head (reads str :: [(Double,String)]))

-- Convert a given string into the corresponding data type or give an error message
-- USAGE: toToken str
toToken :: String -> Token
toToken str 
         | isNumber str   = Num (strToDouble str)
         | isOperator str = Op str
         | otherwise      = Err "[ERROR]: Invalid expression!"

-- Convert a given token into a string
-- USAGE: toString t
toString :: Token -> String
toString (Num n) = show n
toString (Op op) = op
toString (Err e) = e

-- Convert a given list of strings into a list of tokens
-- USAGE: toTokenList lst
toTokenList :: [String] -> [Token]
toTokenList lst = map toToken lst

-- Determine if a Token is a Num or not
-- USAGE: isNum t
isNum :: Token -> Bool
isNum (Num _) = True
isNum _       = False

-- Determine if a Token is an Op or not
-- USAGE: isOp t
isOp :: Token -> Bool
isOp (Op op) = True
isOp _       = False


-- Determine if token is an error or not
-- USAGE: isErr t
isErr :: Token -> Bool
isErr (Err _) = True
isErr _       = False

-- Determine if an operator is Binary or not
-- USAGE: isBinaryOp op
isBinaryOp :: Token -> Bool
isBinaryOp (Op "+")   = True
isBinaryOp (Op "-")   = True
isBinaryOp (Op "*")   = True
isBinaryOp (Op "/")   = True
isBinaryOp _          = False

-- Convert a given string of space separated items into a string of tokens
-- USAGE: tokenize str
tokenize :: String -> [Token]
tokenize str = toTokenList str_tokens
               where str_tokens = words str

-- Given a list of tokens converts it into a human readable string expression
-- USAGE: stringify t_lst
-- stringify :: [Token] -> String
-- stringify []        = ""
-- stringify (car:cdr) = (show car) ++ "\n\n" ++ (stringify cdr)


-- change the '\n' to a space char ' '
repl :: Char -> Char
repl '\n' = ' '
repl c    = c

-- Stack: a list of tokens
-- + first element of the list is the top element of the stack
-- Build stack (pop, push, poppedstack)
-- Return the top element of the stack
pop :: [Token] -> Token
pop stack = head stack


-- Return the stack from the second element onwards
popedStack :: [Token] -> [Token]
popedStack stack = tail stack

-- add a token to the top of the stack
push :: Token -> [Token] -> [Token]
push t stack = [t]++stack


-- _________________OPERAOTRS FOR CALCULATOR___________________________________
-- "+"" operator
plusTokens :: Token -> Token -> Token
plusTokens (Num x) (Num y) = Num (x+y)

-- "-" operator
minusTokens :: Token -> Token -> Token
minusTokens (Num x) (Num y) = Num (x-y)

-- "*" operator
mulTokens :: Token -> Token -> Token
mulTokens (Num x) (Num y) = Num (x*y)

-- "/" operator
divTokens :: Token -> Token -> Token
divTokens (Num x) (Num y) = Num (x/y)

-- apply the operation which is determined by the given operator
applyOp :: String ->[Token] -> [Token]
applyOp "+" arg_stack     = if ((length arg_stack) < 2) 
                            then [(Err "Operator [+]: Not enough arguments!")]
                            else [(plusTokens (pop arg_stack) (pop (popedStack arg_stack)))]++(popedStack (popedStack arg_stack))
applyOp "-" arg_stack     = if ((length arg_stack) < 2) 
                            then [(Err "Operator [-]: Not enough arguments!")]
                            else[(minusTokens (pop (popedStack arg_stack)) (pop arg_stack))]++(popedStack (popedStack arg_stack))
applyOp "*" arg_stack     = if ((length arg_stack) < 2) 
                            then [(Err "Operator [*]: Not enough arguments!")]
                            else[(mulTokens (pop arg_stack) (pop (popedStack arg_stack)))]++(popedStack (popedStack arg_stack))
applyOp "/" arg_stack     = if ((length arg_stack) < 2) 
                            then [(Err "Operator [/]: Not enough arguments!")]
                            else[(divTokens (pop (popedStack arg_stack)) (pop arg_stack))]++(popedStack (popedStack arg_stack))

-- evaluate the expression
-- USAGE: eval tokens arg_stack [arg_stack is passed as an empty list]
eval :: [Token] -> [Token] -> [Token]
eval [] arg_stack = arg_stack
eval (car:cdr) arg_stack
              | (not (null arg_stack)) && (isErr (head arg_stack)) = [(head arg_stack)]
              | isErr car                                          = [car]
              | isNum car                                          = eval cdr (push car arg_stack)
              | isOp  car                                          = eval cdr (applyOp (opStr car) arg_stack)


-- calculate the given string expression in postfix format
-- calc :: String -> String
-- calc [] = "Empty stack!"
-- calc str = show (head result)
--            where result = eval (tokenize str) []
calc :: String -> String
calc [] = "Empty stack!"
calc str = show (head result)
           where result = eval (tokenize str) []--eval (tokenize str) []
           