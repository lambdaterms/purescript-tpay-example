module Types where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Free (Free)
import Hyper.Drive (Application, Request, Response)
import Node.Buffer (BUFFER)
import Node.Crypto (CRYPTO)
import Text.Smolder.Markup (MarkupM)

type Doc e = Free (MarkupM e) Unit

type Code = String

type AppEffect e = (crypto :: CRYPTO, buffer :: BUFFER, console :: CONSOLE | e)

type AppMonad e = Aff (AppEffect e)

type App eff components = Application (AppMonad eff) (Request String components) (Response String)
