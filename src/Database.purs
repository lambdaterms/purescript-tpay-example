module Database where

import Prelude

import Data.Map (Map)
import Data.Map (empty, insert) as Map
import Effect (Effect)
import Effect.Ref (Ref)
import Effect.Ref (modify, modify', new, read) as Ref

type ID = String
type DB a = Map ID a
type Database a = { ref :: Ref (DB a), seq :: Ref Int }

emptyDB :: forall a. Effect (Database a)
emptyDB = do
  ref <- Ref.new (Map.empty)
  seq <- Ref.new 0
  pure { ref, seq }

insert :: forall a. Database a -> a -> Effect ID
insert db val = do
  id ← nextId db.seq
  void $ Ref.modify (Map.insert id val) db.ref
  pure id
  where
    nextId :: Ref Int -> Effect String
    nextId ref = flip Ref.modify' ref \i -> { state : i + 1, value : "prod_" <> show i }

select :: forall a. Database a -> Effect (Map ID a)
select db = Ref.read db.ref

