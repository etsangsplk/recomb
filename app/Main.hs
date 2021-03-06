module Main where

import qualified Light
import qualified Tdfa
import qualified Pcre
import qualified Utils

import qualified Atto
import qualified Atto2
import qualified Parsec
import qualified ParsecV2

import Data.ByteString.Char8 (pack)

import System.IO (readFile)
import Control.Monad (liftM)

import Criterion.Main

main :: IO ()
main = do
  sources <- getLines "sources.txt"
  do defaultMain [
       bgroup "regex" [
           bench "PCRE naive" $ nf (map Pcre.replaceAll) sources
           , env Pcre.compiledRe
             (\ re -> bench "PCRE pre-compiled" $
                      nfIO (mapM_ (Pcre.replaceAll' re) sources))
           , bench "PCRE.Light" $ nf (map Light.replaceAll) sources
           , bench "TDFA" $ nf (map Tdfa.replaceAll) sources
           , bench "PCRE.Utils" $ nf (map Utils.replaceAll) sources
           ]
       , bgroup "combinators" [
           bench "attoparsec" $ nf (map Atto.replaceAll) sources
           , bench "attoparsec2" $ nf (map Atto2.replaceAll) sources
           , bench "parsec3" $ nf (map Parsec.replaceAll) sources
           , bench "parsec3_v2" $ nf (map ParsecV2.replaceAll) sources
           ]
       ]
  where
    getLines = liftM ((map pack) . lines) . readFile
