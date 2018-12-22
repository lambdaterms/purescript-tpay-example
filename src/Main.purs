module Main where

import Prelude

import Control.Monad.Reader (runReaderT)
import Control.Monad.Reader.Class (asks)
import Data.Maybe (Maybe(..))
import Data.Validation.Semigroup (unV)
import Database (emptyDB)
import Debug.Trace (traceM)
import Effect (Effect)
import Effect.Aff.Class (liftAff)
import Effect.Class.Console (log)
import HTTPure as HTTPure
import HTTPure.Response (Response) as HTTPure.Response
import Node.Optlicative (defaultPreferences)
import Node.Optlicative as Optlicative
import Node.Optlicative.Internal (parse) as Optlicative.Internal
import Node.Process (argv)
import Types (AppMonad, TpayConfig)
import Views.Index (view) as Index
import Views.PaymentEndpoint (view) as PaymentEndpoint
import Views.PaymentReturn (view) as PaymentReturn

router :: AppMonad HTTPure.Response.Response
router = do
  request ← asks _.request
  traceM request
  case request of
    { path: [] } → Index.view
    { path: ["payment-return"] } → PaymentReturn.view
    { path: ["payment-confirmation"] } → PaymentEndpoint.view
    otherwise → liftAff $ HTTPure.notFound

tpayConfig ∷ Optlicative.Optlicative TpayConfig
tpayConfig = { id: _, code: _, baseUrl: _ }
  <$> Optlicative.string "tpay-id" Nothing
  <*> Optlicative.string "tpay-secret" Nothing
  <*> Optlicative.string "base-url" Nothing

main :: Effect Unit
main = do
  {cmd, value: opts} ← Optlicative.optlicate
    {}
    Optlicative.defaultPreferences { globalOpts = tpayConfig }
  unV (\err → traceM "Error parsing options") run opts
  where
    run tpay = do
      payments <- emptyDB
      orders <- emptyDB
      let
        context request =
          { tpay
              { id: "35866"
              , code: "2rq73ya5ysjfq7oar04pc3jl7cq55ho"
              , baseUrl: "http://cotidie.serveo.net"
              }
          , orders
          , payments
          , request
          }
      -- runServer defaultOptionsWithLogging components (hyperdrive router)
      HTTPure.serve 3000 (\r → runReaderT router (context r)) do
        log $ " ┌────────────────────────────────┐"
        log $ " │ Server now up on port 3000     │"
        log $ " │                                │"
        log $ " │ To test, run:                  │"
        log $ " │  > curl localhost:3000/        │"
        log $ " │                                │"
        log $ " └────────────────────────────────┘"
