{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
module Gui where

import Control.Concurrent (threadDelay)
import Control.Monad (unless)

-- bytestring
import qualified Data.ByteString.Char8 as C

-- lens
import Control.Lens

-- monomer
import Monomer
import qualified Monomer.Lens as L

-- network
import Network.Socket hiding (send)
import Network.Socket.ByteString

-- text
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T

-- text-show
import TextShow

-- time
import Data.Time.Clock (getCurrentTime)

-- omg
import Omg (parse)


data AppModel = AppModel {
   _clickCount :: Int
  ,_sockPath :: FilePath
  ,_sock :: Socket
  ,_input :: Maybe Text
  ,_output :: Maybe Text
} deriving (Eq, Show)

data AppEvent
  = AppInit
  | AppSetInput Text
  | AppSetOutput (Maybe Text)
  | AppIncrease
  | AppDecrease
  deriving (Eq, Show)

makeLenses 'AppModel

buildUI
  :: WidgetEnv AppModel AppEvent
  -> AppModel
  -> WidgetNode AppModel AppEvent
buildUI wenv model = widgetTree where
  widgetTree = vstack [
      label $ "socket: " <> showt (model ^. sockPath),
      spacer,
      label $ "input: " <> showt (model ^. input),
      spacer,
      hstack [
        spacer,
        button "Inc (I do nothing useful yet)" AppIncrease,
        spacer,
        button "Dec (I do nothing useful yet)" AppDecrease
      ],
      spacer,
      label $ "output: " <> showt (model ^. output)
    ] `styleBasic` [padding 10]

readSocket :: Socket -> (AppEvent -> IO ()) -> IO ()
readSocket sock sendMsg = do
    listen sock 128
    go sock

  where go sock = do
          (conn, _) <- accept sock
          talk conn
          go sock
        talk conn = do
          msg <- recv conn 65536
          unless (C.null msg) $ do
            let txt = T.decodeUtf8 msg
            sendMsg (AppSetInput txt)
            case parse txt of
              Right x -> sendMsg (AppSetOutput (Just x))
              Left err -> sendMsg (AppSetOutput Nothing)

            talk conn

handleEvent
  :: WidgetEnv AppModel AppEvent
  -> WidgetNode AppModel AppEvent
  -> AppModel
  -> AppEvent
  -> [AppEventResponse AppModel AppEvent]
handleEvent wenv node model evt = case evt of
  AppInit -> [Producer (readSocket (model ^. sock))]
  AppSetInput msg -> [Model $ model & input .~ (Just msg)]
  AppSetOutput msg -> [Model $ model & output .~ msg]
  AppIncrease -> [Model (model & clickCount +~ 1)]
  AppDecrease -> [Model (model & clickCount -~ 1)]


start :: IO ()
start = do
  withSocketsDo $ do
    sock <- socket AF_UNIX Stream 0
    bind sock (SockAddrUnix socketPath)
    startApp (model sock) handleEvent buildUI config
    close sock
  where
    socketPath = "/tmp/omgparser.socket"
    config = [
      appWindowTitle "Omg Parser",
      appWindowIcon "./assets/images/icon.png",
      appTheme darkTheme,
      appFontDef "Regular" "./assets/fonts/Roboto-Regular.ttf",
      appInitEvent AppInit
      ]
    model sock = AppModel 0 socketPath sock Nothing Nothing
