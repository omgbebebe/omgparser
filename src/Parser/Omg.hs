{-# language OverloadedStrings #-}
module Parser.Omg (omgP) where

import Control.Monad (void)
import Data.Maybe (catMaybes, listToMaybe)
import Data.Void

-- megaparsec
import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L

-- text
import Data.Text (Text)
import qualified Data.Text as T


type Parser = Parsec Void Text

data Result = Kubectl KubectlCmd | Omg deriving (Eq, Show)

data KVerb
  = Get
  | Create
  deriving (Eq, Show)

data KNoun
  = Pod { podName :: Maybe Text }
  | Service {svcName :: Maybe Text }
  deriving (Eq, Show)

data KOutput = Wide | Json | Yaml | Template | Unknown deriving (Eq, Show)

type KAction = (KVerb, KNoun)

data KubectlCmd = K { action :: KAction, output :: Maybe KOutput } deriving (Eq, Show)

omgP :: Parser Result
omgP = choice
  [Kubectl <$> (string "kubectl" >> char ' ' >> sc >> kubectlP)
  ,Omg     <$ string "omg"
  ]

kubectlP :: Parser KubectlCmd
kubectlP = do
  opts <- optional kubectlOutput
  verb <- choice
    [Get <$ string "get "
    ,Create <$ string "create "
    ]
  opts' <- optional kubectlOutput
  noun <- choice
    [Pod Nothing <$ string "pods"
    ,string "pod " >> (Pod . Just . T.pack) <$> some (alphaNumChar <|> char ',')
    ]
  sc
  opts'' <- optional kubectlOutput

  pure $ K (verb, noun) $ (listToMaybe . catMaybes) [opts, opts', opts'']
--  pure $ K (verb, noun) opts'

kubectlOutput :: Parser KOutput
kubectlOutput = do
  out <- string "-o " >> some (alphaNumChar)
  sc
  pure $ case out of
    "wide" -> Wide
    "json" -> Json
    "yaml" -> Yaml
    "template" -> Template
    _ -> Unknown


-- aux
lineComment :: Parser ()
lineComment = L.skipLineComment "#"

scn :: Parser ()
scn = L.space space1 lineComment empty

sc :: Parser ()
sc = L.space (void $ some (char ' ' <|> char '\t')) lineComment empty
