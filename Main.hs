module Main
  ( main,
  )
where

import AWS.Lambda.RuntimeAPI
import Control.Lens ((%~), deep)
import Data.Aeson (Value (..), decode)
import Data.Aeson.Lens (_String)
import Data.ByteString.Lazy as BL
import Data.String (fromString)
import qualified Data.Text as T
import Protolude

-- toUpper lambda function taken directly from the example at:
-- https://github.com/phadej/aws-lambda-haskell-runtime/blob/master/example/Example.hs
main :: IO ()
main = autoMockJsonMain mock $ \req ->
  return $ requestPayload req & deep _String %~ T.toUpper
  where
    mock =
      Mock
        { mockResponse = print,
          mockRequest = do
            args <- getArgs
            case args of
              -- no arguments: run with @null@
              [] -> mockRequest' Null
              (a : _)
                -- single argument: if looks like valid JSON: use it
                | Just a' <- decode (fromString a :: BL.ByteString) -> mockRequest' a'
                -- otherwise pass as a literal string:
                | otherwise -> mockRequest' (String (fromString a))
        }
    mockRequest' :: Value -> IO (GenRequest Value)
    mockRequest' v = makeMockRequest v 10000 -- 10 seconds
