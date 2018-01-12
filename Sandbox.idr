module Sandbox

%default total
%access export

partial
filter : (a -> Bool) -> Stream a -> Stream a
filter p (x :: xs) = if p x then x :: filter p xs else filter p xs

subsets : List a -> List (List a)
subsets [] = [[]]
subsets (x :: xs) = let xs' = subsets xs in xs' ++ map (x ::) xs'

force : List a -> List a
force = sortBy (const $ const LT)
