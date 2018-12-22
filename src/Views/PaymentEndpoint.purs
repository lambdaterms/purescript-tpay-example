module Views.PaymentEndpoint where

import Prelude

import Control.Monad.Reader.Class (asks)
import Data.Validation.Semigroup (unV)
import Database (insert) as Database
import Debug.Trace (traceM)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import HTTPure (badRequest, ok) as HTTPure
import HTTPure.Response (Response) as HTTPPure.Response
import Tpay (validateResponse) as Tpay
import Types (AppMonad)

view ∷ AppMonad HTTPPure.Response.Response
view = do
  request ← asks _.request
  tpay ← asks _.tpay
  paymentsTable ← asks _.payments
  params <- liftEffect $ Tpay.validateResponse { secret: tpay.code, response: request.body }
  unV
    (\err → do
      traceM err
      -- My own failure protocol ;-)
      liftAff $ HTTPure.badRequest "FAILURE"
    )
    (\resp → do
      void $ liftEffect $ Database.insert paymentsTable resp
      liftAff $ HTTPure.ok "TRUE"
    )
    params

