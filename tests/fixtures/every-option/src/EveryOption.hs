module EveryOption where

import DepA (depA)
import DepB (depB)

answer :: Int
answer = depA + depB
