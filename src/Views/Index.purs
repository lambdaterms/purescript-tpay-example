module Views.Index where

import Prelude

import Control.Monad.Eff.Class (liftEff)
import Data.MediaType.Common (textHTML)
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Database (items)
import Hyper.Drive (Request(..), header, response, status)
import Hyper.Status (statusOK)
import Text.Smolder.HTML (body, form, h1, html, input)
import Text.Smolder.HTML.Attributes as A
import Text.Smolder.Markup (text, (!))
import Text.Smolder.Renderer.String (render)
import Types (App, Components)

index :: forall e. App e Components
index (Request req) = do
  payments <- liftEff $ items req.components.payments
  let 
    doc = html $ do
      body $ do
        h1 (text "Create new transaction")
        (form
          (input ! A.type' "submit"))
          ! A.action "/buy"
          ! A.method "POST"
        h1 (text "Transaction summary")
        (form
          (input ! A.type' "submit"))
          ! A.action "/summary"
          ! A.method "GET"

  response (render doc)
    # status statusOK
    # header (Tuple "Content-Type" (unwrap textHTML))
    # pure
