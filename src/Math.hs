module Math (
  fact,
  factors,
  numOfFactors,
  primes,
  primesBounded,
  isCoprime,
  pascalsTriangle,
  pythagoreanTriple,
  pythagoreanTriples,
  searchPythagoreanTriple) where

import Data.List (sort)

fact :: Integral a => a -> a
fact 2 = 2
fact n = n * fact (n - 1)

factors :: Integral a => a -> [a]
factors n = test $ foldl (\r x -> x : n `div` x : r) []
              [x | x <- [1..truncate $ sqrt $ fromIntegral n], n `mod` x == 0]
  where test (a : xs @ (b : _))
          | a == b = xs
        test xs = xs

numOfFactors :: Integral a => a -> Integer
numOfFactors n = let sqrtN = truncate $ sqrt $ fromIntegral n
                     r = foldl (\r _ -> r + 2) 0
                               [x | x <- [1..sqrtN], n `mod` x == 0]
                  in if sqrtN * sqrtN == n then r - 1 else r

primes :: Integral a => [a]
primes = 2 : filterPrimes [3, 5..]
  where filterPrimes (x : xs) =
          x : filterPrimes (filter (\n -> n `mod` x /= 0) xs)

primesBounded :: Integral a => a -> [a]
primesBounded m = 2 : filterPrimes [3, 5..m]
  where filterPrimes all @ (x : xs)
          | x > bound = all
          | otherwise = x : filterPrimes (filter (\n -> n `mod` x /= 0) xs)
        bound = floor $ sqrt $ fromIntegral m

isCoprime :: Integral a => a -> a -> Bool
isCoprime a b = gcd a b == 1

pascalsTriangle :: Integral a => [[a]]
pascalsTriangle = generate $ repeat 1
  where generate xs = xs : generate (generateRaw 1 $ tail xs)
        generateRaw l (u : r) = let n = l + u
                                 in l : generateRaw n r

pythagoreanTriple :: Integral a => a -> a -> (a, a, a)
pythagoreanTriple m n
  | m <= 0 || n <= 0 = undefined
  | m == n = undefined
  | otherwise =
      sortT3 (abs (m ^ 2 - n ^ 2), 2 * m * n, m ^ 2 + n ^ 2)
  where sortT3 (a, b, c) =
          let [a', b', c'] = sort [a, b, c]
          in (a', b', c')

pythagoreanTriples :: Integral a => [[(a, a, a)]]
pythagoreanTriples = pythagoreanTriples2D 1
  where pythagoreanTriples1D m n
          | isCoprime m n =
              pythagoreanTriple m n :
              pythagoreanTriples1D m (n + 2)
          | otherwise = pythagoreanTriples1D m (n + 2)
        pythagoreanTriples2D m =
          pythagoreanTriples1D m (m + 1) :
          pythagoreanTriples2D (m + 1)

searchPythagoreanTriple :: Integral a => a -> [(a, a, a)]
searchPythagoreanTriple x =
  concatMap (
    concatMap (ti x) .
    filter (\(a, b, c) ->
      x `rem` a == 0 || x `rem` b == 0 || x `rem` c == 0) .
    takeWhile (\(n, _, _) -> n <= x)) $
  takeWhile (\((n, _, _) : _) -> n <= x) pythagoreanTriples
  where ti x (a, b, c) =
          map (\n -> let m = x `quot` n
                      in (a * m, b * m, c * m)) $
          filter ((== 0) . (x `rem`)) [a, b, c]
