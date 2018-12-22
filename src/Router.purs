module Router where

import Prelude

import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.String (take)
-- import Endpoints.Notification (notification)
-- import Hyper.Drive (Request(..), response, status)
-- import Hyper.Status (statusNotFound)
-- import Types (App, Components)
-- import Views.Buy (buy)
-- import Views.Index (index)
-- import Views.Summary (summary)

-- router :: forall e. App e Components
-- router (req@(Request r)) = case r.method of
--   Left GET -> case take 8 r.url of
--     "/summary" -> summary req
--     _ -> index req
--   Left POST -> case r.url of
--     "/notif" -> do
--       notification req
--     "/buy" -> do
--       buy req
--     _ -> 
--       response "Error"
--         # status statusNotFound
--         # pure
--   _ -> 
--     response "Error"
--       # status statusNotFound
--       # pure
