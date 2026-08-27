-- Depends on `safe`, so that a plan carries a package database of a
-- package that the compiler does not ship.
module A (answer) where

import Nested.C (Factor (..), factor)
import Safe (headDef)

answer :: [Int] -> Int
answer counts =
  case factor of
    Factor n -> 42 * n * headDef 1 counts
