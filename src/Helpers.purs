module Helpers where

import Prelude

import API.Tpay.Request (Request, prepareRequest)
import Control.Monad.Eff.Class (liftEff)
import Data.Foldable (sequence_)
import Data.StrMap as StrMap
import Text.Smolder.HTML (form, input)
import Text.Smolder.HTML.Attributes as A
import Text.Smolder.Markup ((!))
import Types (Doc, AppMonad)

buildForm
  :: forall e a
   . String
  -> Request
  -> AppMonad e (Doc a)
buildForm code r = do
  fields <- liftEff $ prepareRequest code r
  let inputs = StrMap.toArrayWithKey buildInput fields
  let
    doc = (form $ do
      sequence_ inputs
      input ! A.type' "submit")
        ! A.action "https://secure.tpay.com"
        ! A.method "POST"
  pure doc
  where
    buildInput key ([v]) =
      input
        ! A.value v
        ! A.name key
        ! A.hidden "true"
    buildInput key _ = pure unit
