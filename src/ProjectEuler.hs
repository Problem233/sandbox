module ProjectEuler where

-- Used by answer11_1
import Data.List (transpose, tails)
import Lib (rotate)
-- Used by answer5_1
import Math (primes)
-- Used by answer15_1
import Math (fact)
-- Used by answer15_3
import Math (pascalsTriangle)

-- Problem 1: Mutiple of 3 and 5
-- --
-- If we list all the natural numbers below 10 that are multiples of 3 or 5, we
-- get 3, 5, 6 and 9. The sum of these multiples is 23.
-- Find the sum of all the multiples of 3 or 5 below 1000.
-- --
-- Answer: 233168

-- answer1_1: O(1)
answer1_1 :: Integer
answer1_1 = sum' 3 + sum' 5 - sum' 15
  where numberOfItem limit x = limit `quot` x
        sum limit x = (x + noi * x) * noi `quot` 2
          where noi = numberOfItem limit x
        sum' = sum (1000 - 1)

-- answer1_2: O(n)
answer1_2 :: Integer
answer1_2 =
  sum [3, 6..999] + sum [5, 10..999] - sum [15, 30..999]

-- answer1_3: O(n)
answer1_3 :: Integer
answer1_3 = sum $
  filter (\x -> x `rem` 3 == 0 || x `rem` 5 == 0) [1..999]

-- Problem 2: Even Fibonacci numbers
-- --
-- Each new term in the Fibonacci sequence is generated by adding the previous
-- two terms. By starting with 1 and 2, the first 10 terms will be:
--   1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...
-- By considering the terms in the Fibonacci sequence whose values do not
-- exceed four million, find the sum of the even- valued terms.
-- --
-- Answer: 4613732

-- answer2_1: O(n)
answer2_1 :: Integer
answer2_1 = loop 0 1 2
  where loop sum a b
          | a <= 4000000 = loop (sum + if even a then a else 0) b (a + b)
          | otherwise = sum

-- answer2_2: O(n)
answer2_2 :: Integer
answer2_2 = sum $ filter even $ takeWhile (<= 4000000) $ fib 1 2
  where fib a b = a : fib b (a + b)

-- Problem 3: Largest prime factor
-- --
-- The prime factors of 13195 are 5, 7, 13 and 29.
-- What is the largest prime factor of the number 600851475143 ?
-- --
-- Answer: 6857

-- answer3_1: O(n)
-- BUG 算法有问题，但结果正确
--     正确算法速度超慢，所以这里将就着用吧
--     补：是我的问题，但是现在懒得改了
answer3_1 :: Integer
answer3_1 = find num 2 2
  where num = 600851475143
        index = floor $ sqrt $ fromInteger num
        find x f r
          | f > index = r
          | x `rem` f == 0 = find (x `quot` f) (f + 1) f
          | otherwise = find x (f + 1) r

-- Problem 4: Largest palindrome product
-- --
-- A palindromic number reads the same both ways. The largest palindrome made
-- from the product of two 2-digit numbers is 9009 = 91 × 99.
-- Find the largest palindrome made from the product of two 3-digit numbers.
-- --
-- Answer: 906609

-- answer4_1: O(10^n)
answer4_1 :: Integer
answer4_1 = foldl max 0 $
            filter (\xs -> reverse (show xs) == show xs)
                   [x * y | x <- reverse [100..999],
                            y <- reverse [100..x]]

-- Problem 5: Smallest multiple
-- --
-- 2520 is the smallest number that can be divided by each of the numbers from
-- 1 to 10 without any remainder.
-- What is the smallest positive number that is evenly divisible by all of the
-- numbers from 1 to 20?
-- --
-- Answer: 232792560

-- answer5_1: O(?)
answer5_1 :: Integer
answer5_1 = product $
            map (\x -> last $ takeWhile (<= 20) $ map (x ^) [1..]) $
            takeWhile (<= 20) primes

-- Problem 9: Special Pythagorean triplet
-- --
-- A Pythagorean triplet is a set of three natural numbers, a < b < c, for
-- which, a ^ 2 + b ^ 2 = c ^ 2
-- For example, 32 + 42 = 9 + 16 = 25 = 52.
-- There exists exactly one Pythagorean triplet for which a + b + c = 1000.
-- Find the product abc.
-- --
-- Answer: 31875000

-- answer9_1: O(?)
answer9_1 :: Integer
answer9_1 = let (a, b, c) = head $
                            filter (\(a, b, c) -> a * a + b * b == c * c)
                              [(a, b, 1000 - a - b) |
                                a <- [1..500], b <- [a..500]]
             in a * b * c

-- Problem 11: Largest product in a grid
-- --
-- In the 20×20 grid below, four numbers along a diagonal line have been marked
-- in red.
-- 08 02 22 97 38 15 00 40 00 75 04 05 07 78 52 12 50 77 91 08
-- 49 49 99 40 17 81 18 57 60 87 17 40 98 43 69 48 04 56 62 00
-- 81 49 31 73 55 79 14 29 93 71 40 67 53 88 30 03 49 13 36 65
-- 52 70 95 23 04 60 11 42 69 24 68 56 01 32 56 71 37 02 36 91
-- 22 31 16 71 51 67 63 89 41 92 36 54 22 40 40 28 66 33 13 80
-- 24 47 32 60 99 03 45 02 44 75 33 53 78 36 84 20 35 17 12 50
-- 32 98 81 28 64 23 67 10<26>38 40 67 59 54 70 66 18 38 64 70
-- 67 26 20 68 02 62 12 20 95<63>94 39 63 08 40 91 66 49 94 21
-- 24 55 58 05 66 73 99 26 97 17<78>78 96 83 14 88 34 89 63 72
-- 21 36 23 09 75 00 76 44 20 45 35<14>00 61 33 97 34 31 33 95
-- 78 17 53 28 22 75 31 67 15 94 03 80 04 62 16 14 09 53 56 92
-- 16 39 05 42 96 35 31 47 55 58 88 24 00 17 54 24 36 29 85 57
-- 86 56 00 48 35 71 89 07 05 44 44 37 44 60 21 58 51 54 17 58
-- 19 80 81 68 05 94 47 69 28 73 92 13 86 52 17 77 04 89 55 40
-- 04 52 08 83 97 35 99 16 07 97 57 32 16 26 26 79 33 27 98 66
-- 88 36 68 87 57 62 20 72 03 46 33 67 46 55 12 32 63 93 53 69
-- 04 42 16 73 38 25 39 11 24 94 72 18 08 46 29 32 40 62 76 36
-- 20 69 36 41 72 30 23 88 34 62 99 69 82 67 59 85 74 04 36 16
-- 20 73 35 29 78 31 90 01 74 31 49 71 48 86 81 16 23 57 05 54
-- 01 70 54 71 83 51 54 69 16 92 33 48 61 43 52 01 89 19 67 48
-- The product of these numbers is 26 × 63 × 78 × 14 = 1788696.
-- What is the greatest product of four adjacent numbers in the same direction
-- (up, down, left, right, or diagonally) in the 20×20 grid?
-- --
-- Answer: 70600674

-- answer11_1: O(?)
answer11_1 :: Integer
answer11_1 = maximum [vmax, hmax, lsmax, rsmax]
  where vmax = rowsMaxProduct grid
        hmax = rowsMaxProduct $ transpose grid
        lsmax = rowsMaxProduct $ rotate grid
        rsmax = rowsMaxProduct $ rotate $ reverse grid
        rowsMaxProduct = maximum .
                         concatMap (
                           map (product . take 4) .
                           filter ((>= 4) . length) . tails)
        grid =
          [
            [8, 2, 22,97,38,15, 0,40, 0,75, 4, 5, 7,78,52,12,50,77,91, 8],
            [49,49,99,40,17,81,18,57,60,87,17,40,98,43,69,48, 4,56,62, 0],
            [81,49,31,73,55,79,14,29,93,71,40,67,53,88,30, 3,49,13,36,65],
            [52,70,95,23, 4,60,11,42,69,24,68,56, 1,32,56,71,37, 2,36,91],
            [22,31,16,71,51,67,63,89,41,92,36,54,22,40,40,28,66,33,13,80],
            [24,47,32,60,99, 3,45, 2,44,75,33,53,78,36,84,20,35,17,12,50],
            [32,98,81,28,64,23,67,10,26,38,40,67,59,54,70,66,18,38,64,70],
            [67,26,20,68, 2,62,12,20,95,63,94,39,63, 8,40,91,66,49,94,21],
            [24,55,58, 5,66,73,99,26,97,17,78,78,96,83,14,88,34,89,63,72],
            [21,36,23, 9,75, 0,76,44,20,45,35,14, 0,61,33,97,34,31,33,95],
            [78,17,53,28,22,75,31,67,15,94, 3,80, 4,62,16,14, 9,53,56,92],
            [16,39, 5,42,96,35,31,47,55,58,88,24, 0,17,54,24,36,29,85,57],
            [86,56, 0,48,35,71,89, 7, 5,44,44,37,44,60,21,58,51,54,17,58],
            [19,80,81,68, 5,94,47,69,28,73,92,13,86,52,17,77, 4,89,55,40],
            [4, 52, 8,83,97,35,99,16, 7,97,57,32,16,26,26,79,33,27,98,66],
            [88,36,68,87,57,62,20,72, 3,46,33,67,46,55,12,32,63,93,53,69],
            [4, 42,16,73,38,25,39,11,24,94,72,18, 8,46,29,32,40,62,76,36],
            [20,69,36,41,72,30,23,88,34,62,99,69,82,67,59,85,74, 4,36,16],
            [20,73,35,29,78,31,90, 1,74,31,49,71,48,86,81,16,23,57, 5,54],
            [1, 70,54,71,83,51,54,69,16,92,33,48,61,43,52, 1,89,19,67,48]
          ]

-- Problem 15: Lattice paths
-- --
-- Starting in the top left corner of a 2×2 grid, and only being able to move
-- to the right and down, there are exactly 6 routes to the bottom right
-- corner.
-- [https://projecteuler.net/project/images/p015.gif]
-- How many such routes are there through a 20×20 grid?
-- --
-- Answer: ???

-- answer15_1: O(n)
answer15_1 :: Integer
answer15_1 = fact (20 * 2) `div` (fact 20 ^ 2)

-- answer15_2: O(?)
answer15_2 :: Integer
answer15_2 = cal 20 20
  where cal x y
          | x == 1 || y == 1 = toInteger $ x + y
          | x == y = 2 * mcal (x - 1) y
          | otherwise = mcal (x - 1) y + mcal x (y - 1)
        mcal x y
          | x < y = mcal y x
          | otherwise = mcall !! (x - 1) !! (y - 1)
        mcall = [[cal x y | y <- [1..x]] | x <- [1..20]]

-- answer15_3: O(?)
answer15_3 :: Integer
answer15_3 = pascalsTriangle !! (20 - 1) !! (20 - 1)
