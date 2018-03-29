module Database where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref (REF, Ref, modifyRef, modifyRef', newRef, readRef)
import Data.StrMap (StrMap)
import Data.StrMap as StrMap

type Transaction = { id :: String, amount :: Number }

type Payment = { id :: String, tpayId :: String, amount :: Number, amountPaid :: Number }

type Database a = { ref :: Ref (DB a), key :: a -> String }

type DB a = StrMap a

type DatabaseConnection e = (ref :: REF | e)

nextId :: forall e. Ref Int -> Eff (DatabaseConnection e) String
nextId ref = modifyRef' ref \i -> { state : i + 1, value : "prod_" <> show i } 

emptyDB :: forall a e. (a -> String) -> Eff (DatabaseConnection e) (Database a)
emptyDB key = do
  ref <- newRef (StrMap.empty)
  pure { ref, key }

insert :: forall a e. Database a -> a -> Eff (DatabaseConnection e) Unit
insert db val =
  let str = db.key val
  in modifyRef db.ref (StrMap.insert str val)

items :: forall a e. Database a -> Eff (DatabaseConnection e) (StrMap a)
items db = readRef db.ref
