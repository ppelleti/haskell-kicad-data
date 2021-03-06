{-# OPTIONS_GHC -fno-warn-orphans #-}
module SExpr
( tests
)
where
import Test.Framework (Test)
import Test.Framework.Providers.QuickCheck2
import Test.QuickCheck
import Control.Monad (liftM)

import Utils

import Data.Kicad.SExpr

tests :: [Test]
tests = [ testProperty "parse all keywords" parseAllKeywords
        ]

parseAllKeywords :: Keyword -> Bool
parseAllKeywords kw = tracedPropEq t1 t2
    where t1 = parse ("(" ++  writeKeyword kw ++ ")")
          t2 = parse $ either id write $ parse ("(" ++  writeKeyword kw ++ ")")

instance Arbitrary SExpr where
    arbitrary = oneof [ liftM AtomKey arbitrary
                      , liftM AtomStr genSafeString
                      , liftM AtomDbl arbitrary
                      , do ls <- arbitrary
                           kw <- elements specialKeywords
                           return $ List $ [AtomKey kw, AtomStr "a", AtomStr "b", AtomStr "c"] ++ ls
                      , do ls <- arbitrary
                           kw <- arbitrary
                           return $ List $ AtomKey kw : ls
                      ]

instance Arbitrary Keyword
    where arbitrary = elements $ filter notSpecial [minBound .. maxBound]
            where notSpecial x = x `notElem` specialKeywords

specialKeywords :: [Keyword]
specialKeywords = [KeyTags, KeyModule, KeyPad, KeyFpText, KeyDescr, KeyTedit]
