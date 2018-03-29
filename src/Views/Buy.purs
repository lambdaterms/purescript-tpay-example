module Views.Buy where
  
import Prelude

import API.Tpay.Request as Tpay
import Control.Monad.Eff.Class (liftEff)
import Data.Maybe (Maybe(..))
import Data.MediaType.Common (textHTML)
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Database (insert, nextId)
import Helpers (buildForm)
import Hyper.Drive (Request(..), header, response, status)
import Hyper.Status (statusOK)
import Text.Smolder.HTML (body, h1, html)
import Text.Smolder.Markup (text)
import Text.Smolder.Renderer.String (render)
import Types (App, Components)

buy :: forall e. App e Components
buy (Request req) = do
  crc <- liftEff $ nextId req.components.idGen
  liftEff $ insert req.components.transactions { id: crc, amount: exampleForm.amount }
  let transaction = exampleForm { crc = Just crc }
  form <- buildForm req.components.code transaction
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
  , crc: Nothing
  }
