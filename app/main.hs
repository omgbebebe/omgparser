module Main where

import Data.List (intercalate)
import System.Environment

-- omg
import Omg
import qualified Gui

main :: IO ()
main = do
  args <- getArgs
  case head args of
    "--gui" -> Gui.start
    _ -> do
      let input = intercalate " " args
      run input
