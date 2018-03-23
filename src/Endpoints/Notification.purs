module Endpoints.Notification where

import Prelude

import API.Tpay.Response (validateResponse)
import Control.Monad.Eff.Class (liftEff)
import Debug.Trace (traceAnyA)
import Hyper.Drive (Request(..), response, status)
import Hyper.Status (statusOK)
import Polyform.Validation (runValidation)
import Types (App, Components)

notification :: forall e. App e Components
notification (Request req) = do
  params <- liftEff $ runValidation (validateResponse req.components.code) req.body
  traceAnyA params
  response "TRUE"
    # status statusOK
    # pure
