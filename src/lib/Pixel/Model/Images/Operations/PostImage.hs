module Pixel.Model.Images.Operations.PostImage
  ( ImageDetails(..)
  , digestImage
  , createImage
  , processImage
  ) where

import Protolude hiding         ( hash )
import Crypto.Hash              ( hash, Digest, SHA3_224 )
import Data.UUID                ( UUID, fromText )
import Data.Time                ( UTCTime )
import Pixel.Model.Token        ( Token (..) )
import Pixel.Model.Images.Types ( Image (..), TagList )
import Pixel.Services.Image     ( MonadImage (..) )
import Pixel.Services.Static    ( MonadStatic (..) )

--------------------------------------------------------------------------------

data ImageDetails = ImageDetails
  { _content      :: !ByteString -- ^ Binary content of the Image to store.
  , _createdAt    :: !UTCTime    -- ^ Time of Upload
  , _directory    :: !Text       -- ^ Where do we store this image?
  , _token        :: !Token      -- ^ Token for user doing this request.
  , _uploadedTags :: !TagList    -- ^ Tags to associate with this image.
  , _uuid         :: !UUID       -- ^ What UUID do we assign to this resouce?
  }

--------------------------------------------------------------------------------

-- | Given a block of bytes, produce a stored image under the hashname of those
-- | bytes. The result of this function is just the hash of the newly created
-- | file within the backend.

createImage
  :: Monad m       -- ^ Any Monad...
  => MonadStatic m -- ^ ... that can store static data
  => MonadImage m  -- ^ ... that can work with Image data
  => ImageDetails  -- ^ The Image we want to upload.
  -> m ()

createImage ImageDetails{..} = do
  let digest = digestImage _content
  let image  = processImage _createdAt _uploadedTags _token _content
  writeStaticImage _directory digest _content
  saveImage _uuid image
  pure ()

--------------------------------------------------------------------------------

-- | Given a block of bytes, what is the hash we should extract? If we ever
-- | change this it will become possible to upload multiple identical images
-- | using a different hash. This may be desireable?

digestImage :: ByteString -> Text
digestImage = show . (hash :: ByteString -> Digest SHA3_224)

-- | Given all uploaded data, produce a valid API image type.
processImage :: UTCTime -> [Text] -> Token -> ByteString -> Image
processImage createdAt newTags token content = Image
  { _hash      = digestImage content
  , _tags      = newTags
  , _uploader  = fromText . _tokenText $ token
  , _createdAt = Just createdAt
  , _deletedAt = Nothing
  }
