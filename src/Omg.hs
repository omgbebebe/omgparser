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

parse :: Text -> Either Text Text
parse input =
  case runParser omgP "some imput name" input of
    Right res -> Right $ T.pack $ show res
    Left err -> Left $ "failed to parse input data"

run :: String -> IO ()
run input = do
  print $ "running with input: " <> input
  case parse (T.pack input) of
    Right res -> T.putStrLn res
    Left err -> T.putStrLn err
