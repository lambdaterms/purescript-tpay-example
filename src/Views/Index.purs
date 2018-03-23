module Views.Index where

import Prelude

import API.Tpay.Request (Request)
import Data.Maybe (Maybe(..))
import Data.MediaType.Common (textHTML)
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Helpers (buildForm)
import Hyper.Drive (header, response, status)
import Hyper.Status (statusOK)
import Text.Smolder.HTML (body, h1, html)
import Text.Smolder.Markup (text)
import Text.Smolder.Renderer.String (render)
import Types (App)

index :: forall e. App e {}
index req = do
  form <- buildForm "demo" exampleForm
  let 
    doc = html $ do
      body $ do
        h1 (text "TPay Api tester")
        form
  response (render doc)
    # status statusOK
    # header (Tuple "Content-Type" (unwrap textHTML))
    # pure

exampleForm :: Request
exampleForm =
  { id: 1010
  , amount: 15.42
  , description: "foo"
  , crc: Just "product_0"
  }