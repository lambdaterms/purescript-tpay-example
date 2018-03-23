module Views.Index where

import Prelude

import API.Tpay.Request as Tpay
import Data.Maybe (Maybe(..))
import Data.MediaType.Common (textHTML)
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Helpers (buildForm)
import Hyper.Drive (Request(..), header, response, status)
import Hyper.Status (statusOK)
import Text.Smolder.HTML (body, h1, html)
import Text.Smolder.Markup (text)
import Text.Smolder.Renderer.String (render)
import Types (App, Components)

index :: forall e. App e Components
index (Request req) = do
  form <- buildForm req.components.code exampleForm
  let 
    doc = html $ do
      body $ do
        h1 (text "TPay Api tester")
        form
  response (render doc)
    # status statusOK
    # header (Tuple "Content-Type" (unwrap textHTML))
    # pure

exampleForm :: Tpay.Request
exampleForm =
  { id: 1010
  , amount: 15.42
  , description: "foo"
  , crc: Just "product_0"
  }
