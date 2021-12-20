--module Hw2
module Hw2 where

--Fibonacci Function
fib :: (Integral a) => a -> a 
fib n = helper 0 1 n 
helper a b 0 = a
helper a b c = helper (a + b) a (c-1)

--Remove Function--
remove::[b]->Int->[b]
remove (x:xs) n
  |n > length (x:xs) =(x:xs)
  |n==1              =xs
  |otherwise         =x:remove xs (n-1)


--lreduce Function--
lreduce :: (a -> a -> a) -> [a] -> a
lreduce funct[y] = y
lreduce funct (y1:y2:xs) = lreduce funct (funct y1 y2 : xs)

addf :: (Num a) => a -> a -> a
addf x y = sum[x,y]

--asum function
asum :: (Num a) => [a] -> a
asum x = foldr (-) 0 x

--xor function--
xor :: [Bool] -> Bool
xor ls = foldr (xorf) False ls 

xorf :: Bool -> Bool -> Bool
xorf m n 
   |m == False && n == False = False
   |m == True && n == True = False
   |otherwise = True





 