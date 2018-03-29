module Endpoints.Notification where

import Prelude

import API.Tpay.Response (validateResponse)
import Control.Monad.Eff.Class (liftEff)
import Database (insert)
import Debug.Trace (traceAnyA)
import Hyper.Drive (Request(..), response, status)
import Hyper.Status (statusOK)
import Polyform.Validation (V(..), runValidation)
import Types (App, Components)

notification :: forall e. App e Components
notification (Request req) = do
  params <- liftEff $ runValidation (validateResponse req.components.code) req.body
  case params of
    Invalid err -> traceAnyA err
    Valid _ resp -> liftEff $ insert req.components.payments resp
  traceAnyA params
  response "TRUE"
    # status statusOK
    # pure
