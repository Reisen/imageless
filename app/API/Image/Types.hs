module API.Image.Types
  ( DigestText
  , Image(..)
  , ImageEvent(..)
  , TagList

  -- Lens
  , imageHash
  , imageTags
  , imageUploader

  -- Prisms
  , _HashChanged
  , _TagAppended
  , _TagRemoved
  , _AssociatedWithUser
  )
where

--------------------------------------------------------------------------------

import           Protolude               hiding ( hash )
import           Control.Lens
import           Data.Aeson                     ( FromJSON, ToJSON )
import           Data.Data                      ( Data )
import           Data.Default.Class             ( Default, def )
import           Data.List                      ( nub, delete )
import           Data.UUID                      ( UUID )
import           Eventless                      ( Project(..), Events )

--------------------------------------------------------------------------------

-- Useful Tag Alises for working with Images
type TagList    = [Text]
type DigestText = Text

--------------------------------------------------------------------------------

-- Define core Image datatype, this defines our representation of any uploaded
-- image when represented in our backend.
data Image = Image
  { _imageHash     :: Text
  , _imageTags     :: [Text]
  , _imageUploader :: Maybe UUID
  } deriving (Show, Generic, Typeable, Data)

-- Derivations
instance ToJSON Image where
instance FromJSON Image where

makeLenses ''Image

--------------------------------------------------------------------------------

-- Define an ImageEvent, so we can emit and project events that happen against
-- an Image in our backend.
data ImageEvent
  = HashChanged Text
  | TagAppended Text
  | TagRemoved Text
  | AssociatedWithUser UUID
  deriving (Show, Generic, Typeable, Data)

-- Derivations
instance ToJSON ImageEvent where
instance FromJSON ImageEvent where

makePrisms ''ImageEvent

--------------------------------------------------------------------------------

-- Associate the Events for Images to be used during projection.
type instance Events Image = ImageEvent

-- Define a Default for it, this is required so we can do persistance with
-- Eventless/Event Sourcing.
instance Default Image where
  def = Image
    { _imageHash     = mempty
    , _imageTags     = mempty
    , _imageUploader = Nothing
    }

-- Provide an Eventless Projection for saving into the backend.
instance Project Image where
  foldEvent image = \case
    HashChanged v        -> image { _imageHash     = v }
    TagAppended v        -> image { _imageTags     = nub (_imageTags image <> [v]) }
    TagRemoved  v        -> image { _imageTags     = delete v (_imageTags image) }
    AssociatedWithUser v -> image { _imageUploader = Just v }
