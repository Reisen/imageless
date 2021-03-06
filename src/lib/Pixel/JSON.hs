{-# LANGUAGE AllowAmbiguousTypes #-}

module Pixel.JSON
  ( createOptions
  , pixelToEncoding
  , pixelToJSON
  , pixelParseJSON
  ) where

import           Protolude
import           Data.String                    ( String )
import qualified Data.Aeson                    as A
import qualified Data.Aeson.Types              as A
import qualified Data.Char                     as C

--------------------------------------------------------------------------------

-- Protolude bans the use of undefined, but we want it here to trick our
-- Generic dataname type to give us the name of _some_ value. So we define our
-- own.
localUndefined :: forall a. a
localUndefined = localUndefined

-- Here we look for any Generic type where the representation is the actual
-- data value name.
dataName
  :: forall a d f. Generic a
  => Rep a ~ D1 d f
  => Datatype d
  => String

dataName = datatypeName (from @a localUndefined)

--------------------------------------------------------------------------------
-- Generic JSON Wrappers
--
-- The default `genericToEncoding` et al from Aeson require that a type
-- implement Generic in order to work. Here, we also require that that type
-- specifically be a `D1` (I.E the actual data-type name) as well. By doing
-- this we can then access the `dataName` of the type we're working with so that
-- we can generically shorten field names:
--
--     _someImageUUID        -> UUID
--     _someImageCreatedDate -> createdDate

-- This function creates, on the fly, a method capable of calculating
-- the right prefix for any type.
createOptions
  :: forall a d f. Generic a
  => Rep a ~ D1 d f
  => Datatype d
  => A.Options

createOptions = A.defaultOptions
  { A.fieldLabelModifier = shortIdentifier (dataName @a)
  }


pixelToEncoding
  :: forall a d f. Generic a
  => Rep a ~ D1 d f
  => Datatype d
  => A.GToEncoding A.Zero (Rep a)
  => a
  -> A.Encoding

pixelToEncoding = A.genericToEncoding (createOptions @a)


pixelToJSON
  :: forall a d f. Generic a
  => Rep a ~ D1 d f
  => Datatype d
  => A.GToJSON A.Zero (Rep a)
  => a
  -> A.Value

pixelToJSON = A.genericToJSON (createOptions @a)


pixelParseJSON
  :: forall a d f. Generic a
  => Rep a ~ D1 d f
  => Datatype d
  => A.GFromJSON A.Zero (Rep a)
  => A.Value
  -> A.Parser a

pixelParseJSON = A.genericParseJSON (createOptions @a)


shortIdentifier
  :: String -- ^ Identifier Prefix
  -> String -- ^ Full Identifier
  -> String -- ^ Identifier Without Prefix / Re-Camelcased

shortIdentifier prefix =
  (>>=)
      (take 1)
      (\t b -> bool (map C.toLower) identity (all C.isUpper b) t <> drop 1 b)
    . drop (length prefix)
    . dropWhile (=='_')

