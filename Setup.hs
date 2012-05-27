import Distribution.Simple (defaultMainWithHooks, simpleUserHooks, hookedPrograms, UserHooks(..))
import Distribution.Simple.Program.Types (simpleProgram)
import Distribution.Simple.Setup (CopyDest(..), installVerbosity, copyVerbosity, fromFlag)
import Distribution.Simple.Utils (createDirectoryIfMissingVerbose, installOrdinaryFile)
import Distribution.Simple.LocalBuildInfo (buildDir, absoluteInstallDirs, InstallDirs(..), LocalBuildInfo(..))
import Distribution.PackageDescription (PackageDescription(..), BuildInfo(..), Executable(..))
import System.Directory (getDirectoryContents)
import System.FilePath ((</>), dropExtension, takeDirectory)
import System.Process (rawSystem)
import Control.Monad (when)
import Data.List (isSuffixOf)
import Data.Maybe (maybe, listToMaybe)

main = defaultMainWithHooks simpleUserHooks
         { hookedPrograms = [simpleProgram "java"]
         , instHook       = ghcjsInstHook
         , copyHook       = ghcjsCopyHook
         }

ghcjsInstHook pkg_descr lbi hooks flags = do
  instHook simpleUserHooks pkg_descr lbi hooks flags
  copyClosure pkg_descr lbi $ fromFlag (installVerbosity flags)

ghcjsCopyHook pkg_descr lbi hooks flags = do
  copyHook simpleUserHooks pkg_descr lbi hooks flags
  copyClosure pkg_descr lbi $ fromFlag (copyVerbosity flags)

-- the closure library has too many files to list manually in a cabal file
-- they are included as .pkg files with "underscore encoding"
decodeUnderscore :: FilePath -> FilePath
decodeUnderscore ('_':'d':xs) = '.' : decodeUnderscore xs
decodeUnderscore ('_':'u':xs) = '_' : decodeUnderscore xs
decodeUnderscore ('_':'s':xs) = '/' : decodeUnderscore xs
decodeUnderscore (x:xs)       = x   : decodeUnderscore xs
decodeUnderscore []           = []

copyClosure pkg_descr lbi verbosity = do
  putStrLn "copying closure"
  let src         = "lib/closure-library/pkg"
      dat         = datadir $ absoluteInstallDirs pkg_descr lbi NoCopyDest
      destination = dat </> "closure-library"
      copy n      = let dstFile = destination </> decodeUnderscore (dropExtension n)
                    in  do createDirectoryIfMissingVerbose verbosity True (takeDirectory dstFile)
                           installOrdinaryFile verbosity (src </> n) dstFile
  files <- getDirectoryContents src
  mapM_ copy $ filter (".pkg" `isSuffixOf`) files


