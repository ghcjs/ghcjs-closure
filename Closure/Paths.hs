module Closure.Paths where

import Paths_ghcjs_closure

-- | The location of the compiler.jar file (includes the file name)
closureCompilerJar :: IO FilePath
closureCompilerJar = getDataFileName "closure-compiler/compiler.jar"

-- | The path in which the Closure Library is installed
closureLibraryPath :: IO FilePath
closureLibraryPath = getDataFileName "closure-library/"
