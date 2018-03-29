module Main where

import Prelude

import API.Tpay.Response (Response)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.AVar (AVAR)
import Control.Monad.Eff.Ref (newRef)
import Database (emptyDB)
import Hyper.Drive (hyperdrive)
import Hyper.Node.Server (defaultOptionsWithLogging, runServer)
import Node.HTTP (HTTP)
import Router (router)
import Types (AppEffect, Components)

type MainEffect e = AppEffect (http :: HTTP, avar :: AVAR | e)

main :: forall e. Eff (MainEffect e) Unit
main = do
  transactions <- emptyDB (_.id)
  let
    pExtr :: Response -> String 
    pExtr = \r -> r.trCrc
  payments <- emptyDB pExtr
  idGen <- newRef 0
  let
    components :: Components
    components =
      { code: "demo"
      , transactions
      , payments
      , idGen
      }
  runServer defaultOptionsWithLogging components (hyperdrive router)
