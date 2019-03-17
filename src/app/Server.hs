module Server
  ( server
  )
where

--------------------------------------------------------------------------------

import           Protolude
import           Servant

import qualified API.Image.Routes                     as API
import qualified Configuration                        as C
import qualified Network.Wai.Middleware.Cors          as Cors
import qualified Network.Wai.Middleware.RequestLogger as Logger
import qualified MonadPixel                           as C

--------------------------------------------------------------------------------

-- Define a Servant API Type
--
-- By using this global API type, we can generate a whole bunch of things
-- automagically, including: an actual server for it, a client, a JS binding, a
-- swagger doc, a mock, etc.

type ImageAPI =
  "image"
    :> (    API.PostImage       -- POST    /image/
       :<|> API.GetImage        -- GET     /image/
       :<|> API.GetImageByUUID  -- GET     /image/:uuid
       :<|> API.GetTags         -- GET     /image/:uuid/tags
       :<|> API.PostTags        -- POST    /image/:uuid/tags
       :<|> API.DeleteTags      -- DELETE  /image/:uuid/tags
       )

type API = "api" :> ImageAPI


-- Proxy for Servant, Ignore.
proxyAPI :: Proxy API
proxyAPI = Proxy


-- Wrap up our actual methods, here we have to chain our methods in the same
-- order our API type above expects them to be in.
implAPI :: ServerT API C.Pixel
implAPI =
  API.postImage
    :<|> API.getImage
    :<|> API.getImageByUUID
    :<|> API.getTags
    :<|> API.postTags
    :<|> API.deleteTags

--------------------------------------------------------------------------------

-- Create a Servant Server to run in WAI.
server :: C.Config -> Application
server config =
  Logger.logStdout
    $ corsHandler
    $ serve proxyAPI
    $ hoistServer proxyAPI (C.runPixel config) implAPI

  where
    corsHandler =
      Cors.cors . const $ Just $ Cors.simpleCorsResourcePolicy
        { Cors.corsRequestHeaders =
          [ "Content-Type"
          , "Authorization"
          ]
        }