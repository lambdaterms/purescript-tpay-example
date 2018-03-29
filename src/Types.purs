module Types where

import Prelude

import API.Tpay.Response as API
import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Ref (Ref)
import Control.Monad.Free (Free)
import Database (Database, Transaction, DatabaseConnection)
import Hyper.Drive (Application, Request, Response)
import Node.Buffer (BUFFER)
import Node.Crypto (CRYPTO)
import Text.Smolder.Markup (MarkupM)

type Doc e = Free (MarkupM e) Unit

type Code = String

type Components = 
  { code :: Code
  , transactions :: Database Transaction
  , payments :: Database API.Response
  , idGen :: Ref Int
  }

type AppEffect e =
  DatabaseConnection 
    ( crypto :: CRYPTO
    , buffer :: BUFFER
    , console :: CONSOLE
    | e)

type AppMonad e = Aff (AppEffect e)

type App eff components = Application (AppMonad eff) (Request String components) (Response String)
