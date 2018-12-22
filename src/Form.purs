module Form where

import Prelude

import Data.Array (head, singleton) as Array
import Data.Decimal (Decimal)
import Data.Decimal (toString) as Decimal
import Data.Map (lookup, singleton) as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (wrap)
import Data.Tuple (Tuple(..))
import Data.Variant (Variant)
import Polyform.Dual (Dual, dual, serializer) as Dual
import Polyform.Dual (parser) as Polyform.Dual
import Polyform.Dual.Reporter (hoistValidatorWith) as Dual.Reporter
import Polyform.Dual.Validators.UrlEncoded (Decoded(..))
import Polyform.Dual.Validators.UrlEncoded (query, string) as Dual.Validators.Urlencoded
import Polyform.Reporter (Reporter, hoistFnMR, hoistValidatorWith, runReporter) as Reporter
import Polyform.Validator (Validator) as Validator
import Polyform.Validators.UrlEncoded (Decoded) as Urlencoded
import Polyform.Validators.UrlEncoded (Error) as Validators.UrlEncoded
import Tpay.Validators (decimal) as Tpay.Validators
import Type.Row (type (+))

-- | Simple form validation framework built on top of polyform-validators.

type Error = String

type Field =
  { label ∷ String
  , name ∷ String
  , value ∷
      { raw ∷ String
      , error ∷ Maybe String
      }
  }

-- | Form consists of:
-- | * form level errors (currently only query validation errors)
-- | * fields build from query values
-- |
-- | It is a `Tuple` so we get `Monoid` for free.
type Form = Tuple
  (Array (Variant (Validators.UrlEncoded.Error + ())))
  (Array Field)

type Reporter m a = Reporter.Reporter m Form Urlencoded.Decoded a

field ∷ ∀ a m
  . Monad m
  ⇒ { dual ∷ Dual.Dual (Validator.Validator m String) (Maybe (Array String)) a
    , label ∷ String
    , name ∷ String
    }
  → Dual.Dual (Reporter.Reporter m Form) Decoded a
field { label, name, dual } = Dual.dual
  { parser
  , serializer
  }
  where
    serializer = Dual.serializer dual >>> fromMaybe [] >>> Map.singleton name >>> wrap
    parser = Reporter.hoistFnMR $ \(Decoded query) → do
      let
        validator = Polyform.Dual.parser dual
        input = Map.lookup name query
        hoistValidator = Reporter.hoistValidatorWith
          (build <<< Tuple input <<< Just)
          (const $ build (Tuple input Nothing))
      Reporter.runReporter (hoistValidator validator) input
      where
        build (Tuple raw error) = Tuple [] [{ label, name, value: { raw: toString raw, error }}]
        toString queryValue = fromMaybe "" (queryValue >>= Array.head)

decimal ∷ ∀ m
  . Monad m
  ⇒ { label ∷ String, name ∷ String }
  → Dual.Dual (Reporter.Reporter m Form) Decoded Decimal
decimal { label, name } = field { label, name, dual }
  where
    dual = Dual.dual
      { parser: Tpay.Validators.decimal
      , serializer: Just <<< Array.singleton <<< Decimal.toString
      }

string ∷ ∀ m
  . Monad m
  ⇒ { label ∷ String, name ∷ String }
  → Dual.Dual (Reporter.Reporter m Form) Decoded String
string { label, name } = field { label, name, dual: Dual.Validators.Urlencoded.string }


-- | Take fields dual which acts upon parsed query and build a string
-- | based chain of validation / serialization.
form ∷ ∀ a m
  . Monad m
  ⇒ Dual.Dual (Reporter.Reporter m Form) Decoded a
  → Dual.Dual (Reporter.Reporter m Form) String a
form fields = queryDual >>> fields
  where
    queryDual = Dual.Reporter.hoistValidatorWith
      (flip Tuple [])
      (const $ mempty)
      (Dual.Validators.Urlencoded.query { replacePlus: true })

