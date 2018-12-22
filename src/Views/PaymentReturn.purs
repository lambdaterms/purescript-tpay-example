module Views.PaymentReturn where

import Prelude

import HTTPure.Response (Response) as HTTPPure.Response
import Text.Smolder.HTML (a, body, p) as M
import Text.Smolder.HTML.Attributes (href) as A
import Text.Smolder.Markup ((!))
import Text.Smolder.Markup (text) as M
import Types (AppMonad)
import Views (htmlOk) as Views

view ∷ AppMonad HTTPPure.Response.Response
view = Views.htmlOk $ M.body $ do
  M.p $
    M.text $
      ("Thanks for your order! Confirmation should arive soon." <>
       " Please go to index page and refresh a page few times ;-)")
  M.p $
    (M.a ! A.href "/" $ M.text "Home")
