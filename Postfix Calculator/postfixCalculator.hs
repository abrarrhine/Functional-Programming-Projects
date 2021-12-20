{--
I have neither given nor received unauthorized assistance on this assignment.
--Abrar Islam (abrarr18)
--}

import System.Environment
import System.IO

main :: IO ()
main = do
        args <- getArgs
        let files = get_names args
        let input = fst files 
        let output = snd files
        putStrLn input
        putStrLn output
        in_handle <- openFile input ReadMode
        out_handle <- openFile output WriteMode
        mainloop in_handle out_handle
        hClose in_handle
        hClose out_handle         

mainloop :: Handle -> Handle -> IO ()
mainloop in_handle out_handle = 
        do in_eof <- hIsEOF in_handle
           if in_eof
                then return ()
                else do line <- hGetLine in_handle
                        putStrLn $ "line " ++ line
                        let line_words = words line  
                        putStr "\tWords: "
                        print line_words
                        hPutStr out_handle (line) 
                        calculator line_words [] out_handle
                        mainloop in_handle out_handle

get_names :: [String] -> (String, String)
get_names (arg1:arg2:_) =
        let in_file = arg1
            out_file = arg2
        in (in_file, out_file)

{-- 
This function calculates the postfix string and returns the result or 
sends out error message if there is any invalid calculation
--}
calculator :: [String] -> [Integer] -> Handle -> IO()
calculator [] [x] out_handle = hPutStrLn out_handle (" = " ++ show x)
calculator [] (x1:x2) out_handle = hPutStrLn out_handle ("\n\t\t\tToo few operations")
calculator ("/":xs) (x2:x1:lst) out_handle
        | x2 == 0 = hPutStrLn out_handle ("\n\t\t\tAttempted division by 0")
        | otherwise = do
                let result = divide x1 x2
                calculator xs (result:lst) out_handle
calculator ("+":xs) (x2:x1:lst) out_handle = do
        let result = addition x1 x2
        calculator xs (result:lst) out_handle
calculator ("-":xs) (x2:x1:lst) out_handle = do
        let result = subtraction x1 x2
        calculator xs (result:lst) out_handle
calculator ("*":xs) (x2:x1:lst) out_handle = do
        let result = multiplication x1 x2
        calculator xs (result:lst) out_handle

calculator (x:xs) (lst) out_handle
        |isErrorMessage x == True = hPutStrLn out_handle ""
        |otherwise = calculator xs ((read x :: Integer):lst) out_handle
               
calculator [x] [x1] out_handle = hPutStrLn out_handle ("\n\t\t\tToo few operands")

-- This function adds two numbers
addition ::  Integer -> Integer -> Integer
addition x y = x + y

--This function subtracts second number from first one
subtraction :: Integer -> Integer -> Integer
subtraction x y = x - y

--This function multiplies two numbers
multiplication :: Integer -> Integer -> Integer
multiplication x y = x * y

--This function divides first number by second number
-- Using "/" instead of `div` would cause fractional integer error
divide :: Integer -> Integer -> Integer
divide x y = x `div` y

-- This function prints out the error message 
isErrorMessage :: String -> Bool
isErrorMessage str 
        |str == "Too" = True
        |otherwise = False


