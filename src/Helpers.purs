module Helpers where

import Prelude

import API.Tpay.Request (Request, prepareRequest)
import API.Tpay.Serialize (class Serialize, serialize)
import Control.Monad.Eff.Class (liftEff)
import Data.Foldable (sequence_)
import Data.StrMap (StrMap)
import Data.StrMap as StrMap
import Text.Smolder.HTML (form, input)
import Text.Smolder.HTML.Attributes as A
import Text.Smolder.Markup ((!))
import Types (Doc, AppMonad)

inputs :: forall a r. Serialize r => r -> Array (Doc a)
inputs r = inputs' $ serialize r 

inputs' :: forall a. StrMap (Array String) -> Array (Doc a)
inputs' m = StrMap.toArrayWithKey buildInput m
  where
    buildInput key ([v]) =
      input
        ! A.value v
        ! A.name key
    buildInput key _ = pure unit

buildForm
  :: forall e a
   . String
  -> Request
  -> AppMonad e (Doc a)
buildForm code r = do
  fields <- liftEff $ prepareRequest code r
  let inputs = map (_ ! A.hidden "true") $ inputs' fields
  let
    doc = (form $ do
      sequence_ inputs
      input ! A.type' "submit")
        ! A.action "https://secure.tpay.com"
        ! A.method "POST"
  pure doc
