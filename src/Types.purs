module Types where

import Control.Monad.Reader (ReaderT)
import Data.Decimal (Decimal)
import Database (Database)
import Effect.Aff (Aff)
import HTTPure.Request (Request) as HTTPure
import Tpay.Response (Response) as Tpay

type Order = { amount ∷ Decimal, description ∷ String }

type Payment = Tpay.Response -- { id ∷ Int, tpayId ∷ String, amount ∷ Number, amountPaid ∷ Number }

type TpayConfig =
  { code ∷ String
  , id ∷ String
  , baseUrl ∷ String
  }

type Context =
  { orders ∷ Database Order
  , payments ∷ Database Payment
  , request ∷ HTTPure.Request
  , tpay ∷ TpayConfig
  }

type AppMonad a = ReaderT Context Aff a

