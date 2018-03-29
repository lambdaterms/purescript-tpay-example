module Views.Buy where
  
import Prelude

import API.Tpay.Request (defaultRequest)
import API.Tpay.Request as Tpay
import API.Tpay.Validators (Validator)
import API.Tpay.Validators as Validators
import Control.Monad.Eff.Class (liftEff)
import Data.Maybe (Maybe(..))
import Data.MediaType.Common (textHTML)
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Database (insert, nextId)
import Debug.Trace (traceAnyA)
import Helpers (buildForm)
import Hyper.Drive (Request(..), header, response, status)
import Hyper.Status (statusNotFound, statusOK)
import Polyform.Validation (V(..), runValidation)
import Text.Smolder.HTML (body, h1, html)
import Text.Smolder.Markup (text)
import Text.Smolder.Renderer.String (render)
import Types (App, Components)

buy :: forall e. App e Components
buy (Request req) = do
  crc <- liftEff $ nextId req.components.idGen
  params <- liftEff $ runValidation validateParams req.body
  case params of
    Invalid err -> do
      traceAnyA err
      response "Error"
        # status statusNotFound
        # pure
    Valid _ { amount, desc } -> do
      liftEff $ insert req.components.transactions { id: crc, amount: amount }
      let transaction = exampleForm amount desc crc
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

exampleForm :: Number -> String -> String -> Tpay.Request
exampleForm amount description crc = (defaultRequest
  { id: 1010
  , amount
  , description
  }) 
    { crc = Just crc
    , email = Just "email@example.com"
    , name = Just "Example Man"
    , accept_tos = Just 1
    }

validateParams :: forall m. Monad m => Validator m String { amount:: Number, desc:: String }
validateParams = Validators.response >>> ({ amount: _, desc: _} 
  <$> (Validators.selectField "amount" >>> Validators.number)
  <*> Validators.selectField "desc")
