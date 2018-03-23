module Main where

import Prelude

import API.Tpay.Request as Tpay
import Control.IxMonad (ibind, (:*>))
import Control.Monad.Aff (Aff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Free (Free)
import Data.Either (Either(..))
import Data.Foldable (sequence_)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.MediaType.Common (textHTML)
import Data.Newtype (unwrap)
import Data.StrMap as StrMap
import Data.Tuple (Tuple(..))
import Hyper.Conn (Conn)
import Hyper.Drive (Application, header, hyperdrive, response, status)
import Hyper.Drive as HD
import Hyper.Middleware (Middleware(..))
import Hyper.Node.Server (defaultOptionsWithLogging, runServer)
import Hyper.Request (class ReadableBody, class Request, getRequestData)
import Hyper.Response (class Response, class ResponseWritable, ResponseEnded, StatusLineOpen, closeHeaders, respond, writeStatus)
import Hyper.Status (statusNotFound, statusOK)
import Node.Buffer (BUFFER)
import Node.Crypto (CRYPTO)
import Node.HTTP (HTTP)
import Text.Smolder.HTML (body, h1, form, input)
import Text.Smolder.HTML.Attributes as A
import Text.Smolder.Markup (MarkupM, text, (!))
import Text.Smolder.Renderer.String (render)

type Doc e = Free (MarkupM e) Unit

buildForm
  :: forall e a
   . String
  -> Tpay.Request
  -> FormAff e (Doc a)
buildForm code r = do
  fields <- liftEff $ Tpay.prepareRequest code r
  let inputs = StrMap.toArrayWithKey buildInput fields
  let
    doc = (form $ do
      sequence_ inputs
      input ! A.type' "submit")
        ! A.action "https://secure.tpay.com"
        ! A.method "POST"
  pure doc
  where
    buildInput key ([v]) = input ! A.value v ! A.name key
    buildInput key _ = pure unit

type FormAff e = Aff (crypto :: CRYPTO, buffer :: BUFFER, console :: CONSOLE | e)

exampleForm =
  { id: 1010
  , amount: 15.42
  , description: "foo"
  , crc: Nothing
  }

index
  :: forall e
   . Applicative (FormAff e)
  => Application (FormAff e) (HD.Request String {}) (HD.Response String)
index _ = do
  f <- buildForm "demo" exampleForm
  let
    resp = response
      (render $ body $ do
        h1 (text "Hello from Smolder!")
        f)
      # status statusOK
      # header (Tuple "Content-Type" (unwrap textHTML))
  pure resp

indexMiddleware
  :: forall b eff req res
   . Request req (FormAff eff)
  => Response res (FormAff eff) b
  => ReadableBody req (FormAff eff) String
  => ResponseWritable b (FormAff eff) String
  => Middleware
    (FormAff eff)
    (Conn req (res StatusLineOpen) {})
    (Conn req (res ResponseEnded) {})
    Unit
indexMiddleware = hyperdrive index

notif
  :: forall e
   . Application (FormAff e) (HD.Request String {}) (HD.Response String)
notif (HD.Request r) = do
  liftEff $ log r.body
  pure $
    response "TRUE"
    # status statusOK

router
  :: forall b eff req res
   . Request req (FormAff eff)
  => Response res (FormAff eff) b
  => ReadableBody req (FormAff eff) String
  => ResponseWritable b (FormAff eff) String
  => Middleware
    (FormAff eff)
    (Conn req (res StatusLineOpen) {})
    (Conn req (res ResponseEnded) {})
    Unit
router = do
  dat <- getRequestData
  case dat.method of
    Left GET -> indexMiddleware
    Left POST -> hyperdrive notif
    _ -> do
      writeStatus statusNotFound
      :*> closeHeaders
      :*> respond "Nothing to be found here"
  where
  bind = ibind


main :: forall e. Eff (crypto :: CRYPTO, console :: CONSOLE, buffer :: BUFFER, http :: HTTP, avar :: AVAR | e) Unit
main = runServer defaultOptionsWithLogging {} (hyperdrive index)
