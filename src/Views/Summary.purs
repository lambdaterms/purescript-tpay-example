module Views.Summary where

import Prelude

import API.Tpay.Serialize (class Serialize, serialize)
import Control.Monad.Eff.Class (liftEff)
import Data.Foldable (sequence_, traverse_)
import Data.MediaType.Common (textHTML)
import Data.Newtype (unwrap)
import Data.StrMap as StrMap
import Data.Tuple (Tuple(..))
import Database (items)
import Hyper.Drive (Request(..), header, response, status)
import Hyper.Status (statusOK)
import Text.Smolder.HTML (body, h1, html, li, p, ul)
import Text.Smolder.Markup (text)
import Text.Smolder.Renderer.String (render)
import Types (App, Components, Doc)

summary :: forall e. App e Components
summary (Request req) = do
  payments <- liftEff $ items req.components.payments
  transactions <- liftEff $ items req.components.transactions
  let 
    doc = html $ do
      body $ do
        h1 (text "Recorded payments")
        traverse_ renderRecord payments
        h1 (text "Recorded transactions")
        traverse_ renderRecord transactions

  response (render doc)
    # status statusOK
    # header (Tuple "Content-Type" (unwrap textHTML))
    # pure

renderRecord :: forall a r. Serialize r => r -> Doc a
renderRecord r = p $ ul $ do
  sequence_ (StrMap.mapWithKey (\s v -> li $ text (s <> show v)) $ serialize r)
