module Router where

import Prelude

import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Endpoints.Notification (notification)
import Hyper.Drive (Request(..), response, status)
import Hyper.Status (statusNotFound)
import Types (App, Components)
import Views.Index (index)

router :: forall e. App e Components
router (req@(Request r)) = case r.method of
  Left GET ->  index req
  Left POST -> notification req
  _ -> 
    response "Error"
      # status statusNotFound
      # pure
