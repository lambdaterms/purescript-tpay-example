module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.AVar (AVAR)
import Hyper.Drive (hyperdrive)
import Hyper.Node.Server (defaultOptionsWithLogging, runServer)
import Node.HTTP (HTTP)
import Router (router)
import Types (AppEffect)

type MainEffect e = AppEffect (http :: HTTP, avar :: AVAR | e)

main :: forall e. Eff (MainEffect e) Unit
main = runServer defaultOptionsWithLogging {} (hyperdrive router)
