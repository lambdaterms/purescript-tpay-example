module Views where

import Prelude

import Control.Monad.Reader.Class (asks)
import Effect.Aff.Class (liftAff)
import Form (Field) as Form
import HTTPure (Request, found', header, ok') as HTTPure
import HTTPure.Response (Response) as HTTPure.Response
import Text.Smolder.HTML (html, input) as M
import Text.Smolder.HTML.Attributes as A
import Text.Smolder.Markup (Markup, (!))
import Text.Smolder.Renderer.String (render) as Smolder
import Types (AppMonad)

request ∷ AppMonad HTTPure.Request
request = asks _.request

input ∷ ∀ a. Form.Field → Markup a
input { label, name, value: { raw }} =
  M.input
    ! A.value raw
    ! A.name name

htmlOk ∷ ∀ a. Markup a → AppMonad HTTPure.Response.Response
htmlOk = liftAff <<< HTTPure.ok' (HTTPure.header "Content-Type" "text/html") <<<  Smolder.render <<< M.html

redirect ∷ String → AppMonad HTTPure.Response.Response
redirect location = liftAff $ HTTPure.found' (HTTPure.header "Location" location) ""
