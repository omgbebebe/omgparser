module Main where

import Data.List (intercalate)
import System.Environment

-- omg
import Omg

main :: IO ()
main = do
  args <- getArgs
  let input = intercalate " " args
  run input
