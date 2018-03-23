module Endpoints.Notification where

import Prelude

import API.Tpay.Response (validateResponse)
import Control.Monad.Eff.Class (liftEff)
import Debug.Trace (traceAnyA)
import Hyper.Drive (Request(..), response, status)
import Hyper.Status (statusOK)
import Polyform.Validation (runValidation)
import Types (App)

notification :: forall e. App e {}
notification (Request req) = do
  params <- liftEff $ runValidation (validateResponse "demo") req.body
  traceAnyA params
  response "TRUE"
    # status statusOK
    # pure
