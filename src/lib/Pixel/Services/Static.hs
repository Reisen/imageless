module Pixel.Services.Static
  ( MonadStatic (..)
  ) where

import Protolude

--------------------------------------------------------------------------------

-- Tagless Final provider for methods that deal with physical byte persistance
-- of images. The API uses hashes as target file names for easy deduplication.

class MonadStatic m where
  -- Given a static directory, a hash of the file, and the contents itself,
  -- persist the data to disk.
  writeStaticImage
    :: Text       -- ^ Path to Base Directory
    -> Text       -- ^ Hash of ByteString
    -> ByteString -- ^ Content to Write
    -> m ()
