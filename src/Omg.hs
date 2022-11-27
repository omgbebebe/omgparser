{-# language OverloadedStrings #-}
module Omg where

-- megaparsec
import Text.Megaparsec (parseTest, runParser)

-- text
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T

-- omg
import Parser.Omg (omgP)

run :: String -> IO ()
run input = do
  print $ "running with input: " <> input
  case runParser omgP "some imput name" (T.pack input) of
    Right res -> T.putStrLn $ "Parser command is:\n" <> (T.pack $ show res)
    Left err -> T.putStrLn $ "failed to parse input data"
