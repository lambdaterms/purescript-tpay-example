module Views.Index where

import Prelude

import Control.Monad.Reader.Class (asks)
import Data.Decimal (Decimal)
import Data.Decimal (fromNumber) as Decimal
import Data.Foldable (for_)
import Data.FoldableWithIndex (forWithIndex_)
import Data.Map (Map) as Map
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Database (insert, select) as Database
import Effect.Class (liftEffect)
import Form as Form
import Global.Unsafe (unsafeStringify)
import HTTPure as HTTPure
import HTTPure.Response (Response) as HTTPPure.Response
import Polyform.Dual ((>-))
import Polyform.Dual (Dual(..)) as Dual
import Polyform.Dual.Reporter (runReporter, runSerializer) as Dual.Reporter
import Polyform.Reporter (R(..))
import Polyform.Reporter (Reporter) as Reporter
import Text.Smolder.HTML (body, form, h1, input, li, ul) as M
import Text.Smolder.HTML.Attributes as A
import Text.Smolder.Markup ((!))
import Text.Smolder.Markup (Markup, text) as M
import Tpay (defaultRequest, getUrl) as Tpay
import Types (AppMonad)
import Views (htmlOk, redirect)
import Views (input) as Views

orderReporter ∷ ∀ m
  . Monad m
  ⇒ Dual.Dual
     (Reporter.Reporter m Form.Form)
     String
     { amount ∷ Decimal
     , description ∷ String
     }
orderReporter
  = Form.form $ Dual.Dual $ { amount: _, description: _ }
  <$> _.amount >- Form.decimal { label: "amount", name: "amount" }
  <*> _.description >- Form.string { label: "description", name: "desc" }

view ∷ AppMonad HTTPPure.Response.Response
view = do
  request ← asks _.request
  payments ← asks _.payments >>= Database.select >>> liftEffect
  orders ← asks _.orders >>= Database.select >>> liftEffect
  case request.method of
    HTTPure.Post → do
      form ← liftEffect $ Dual.Reporter.runReporter orderReporter request.body
      case form of
        Success _ order → do
          orderId ← addOrder order
          redirectTo ← tpayUrl orderId order
          redirect redirectTo
        Failure _ →
          template { form, orders, payments }
    otherwise → do
      query ← liftEffect $ Dual.Reporter.runSerializer orderReporter
        { amount: Decimal.fromNumber 9.5, description: "desc" }
      form ← liftEffect $ Dual.Reporter.runReporter orderReporter query
      template { form, orders, payments }
  where
    template { form, orders, payments } = htmlOk $ do
      M.body $ do
        M.h1 (M.text "Create new order")
        M.form ! A.method "POST" $ do
          case form of
            Success (Tuple e fields) _ → for_ fields Views.input
            Failure _ → M.text "validation failed"
          M.input ! A.type' "submit"
        let
          listRecords :: forall a r. Map.Map String r -> M.Markup a
          listRecords rs = M.ul $
            forWithIndex_ rs \id r → M.li $ M.text (unsafeStringify { id, r })
        M.h1 (M.text "Order")
        listRecords orders
        M.h1 (M.text "Payments")
        listRecords payments

    addOrder order = do
      ordersTable ← asks _.orders
      liftEffect $ Database.insert ordersTable order

    tpayUrl orderId order = do
      tpay ← asks _.tpay
      let
        request =
          (Tpay.defaultRequest { id: tpay.id, amount: order.amount, description: order.description })
            { accept_tos = Just 1
            , crc = Just orderId
            , email = Just "email@example.com"
            , name = Just "Example Man"
            , return_url = Just (tpay.baseUrl <> "/payment-return")
            , result_url = Just (tpay.baseUrl <> "/payment-confirmation")
            }
      liftEffect $ Tpay.getUrl { code: tpay.code, request }
