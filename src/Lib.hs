module Lib (
  module ExportedModules,
  renderSnd,
  myWind,
  spinFull, spin,
  tempo,
  Note, Score,
  note, notes,
  renderScore, guitarPlay,
  twinkle) where

import Data.Char (isDigit)
import Csound.Base as ExportedModules hiding (tempo)
import Csound.Patch as ExportedModules

renderSnd :: RenderCsd a => String -> a -> IO ()
renderSnd = writeSndBy $ setRates 48000 64 <>
              def {
                csdFlags = def {
                  audioFileOutput = def {
                    formatSamples = Just Bit24
                  }
                }
              }

myWind :: SE Sig
myWind = osc . (\x -> 220 + 88 * (osc x + x)) <$> pink

spinFull :: Sig -> Sig -> Sig2
spinFull f x = let l = (osc f + 1) / 2
                   r = 1 - l
                 in at ((l, r) *) x

-- | Spins the sound around.
spin :: Sig -- ^ The amount of the sound saved in both left and right. 
            -- This argument should be @< 1@ and @>= 0@,
            -- or unknown error may occur.
     -> Sig -- ^ The frequency of spinning.
     -> Sig -- ^ The input signal.
     -> (Sig, Sig)
spin base f x = at (\x' -> base * x + (1 - base) * x') (spinFull f x)

-- | Sets the tempo of a score
-- Shouldn't be applied to a score twice.
tempo :: D -> Score -> Score
tempo t = str (60 / sig t)

type Note = CsdNote D
type Score = Sco Note

note :: String -> Score
note s =
  case last s of
    '^' -> let (len, note') = span (== '^') $ reverse s
            in str (1 / 2 ^ length len) $ note $ reverse note'
    '~' -> let (len, note') = span (== '~') $ reverse s
            in str (sig $ int $ 1 + length len) $ note $ reverse note'
    _ -> mkNote s
  where mkNote "0" = rest 1
        mkNote s = temp (0.5, cpsmidinn $ ntom $ text s)

-- TODO make it more friendly
-- eg. (3A 3B)^ 4C - 0 |
-- eg. 4C^ . 4D^^ |
notes :: String -> Score
notes = mel . fmap note . filter (isDigit . head) . words

renderScore :: (RenderCsd t, Sigs t) => (Score -> Sco (Mix t)) -> Score -> IO ()
renderScore instr score = dac $ mix $ instr score

guitarPlay :: Score -> IO ()
guitarPlay = renderScore $ atSco guitar

twinkle :: Score
twinkle = tempo 100 $ mel [pA, pB, pA]
  where
    pA = notes "4C 4C | 4G 4G | 4A 4A | 4G~ - | 4F 4F | 4E 4E | 4D 4D | 4C~ - |"
    pB = notes "4G 4G | 4F 4F | 4E 4E | 4D~ - | 4G 4G | 4F 4F | 4E 4E | 4D~ - |"

test :: Score
test = tempo 100 $ notes
  "3A^ 3B^ 4C~~ - - | 3A^ 3B^ 4C~~ - - | 3B^ 4C^ 4D~~ - - | 4C^ 3B^ 3A~~ - - ||"

-- | This melody has been used in my music homework.
-- TODO Needs to be rewrited after `notes` is reworked.
test2 :: Score
test2 = tempo 160 $ notes $ unwords [
  "4F 4C^ 4F 5C^ 0^ 4B~ 4A^~~~~ |",
  "4E^ 4F^ 4G^ 4F^ 0^ 4E^ 0^ 4D^ 0^ 4E^ 0^ 4F^~~ 4G ||"]

-- | This melody requires to be edited to satisfy rhythm.
test3 :: Score
test3 = tempo 120 $ notes $ unwords [
  "[ 4C^ 3B^ ] 4C~ - 3F | 4C 4D 4C^ 3B [4.5] | 4C 3A~ 0^ [3.5] | 0 0 0 0 |",
  "[ 3A^ 3B^ ] 4C~ - 3B | 4C 4D 4C^ 4D [4.5] | 4F 4E~ 4D^ [3.5] | 4C~ - 0 0 |",
  "[ 4C^ 4D^ ] 4E~ - 4D^ 4E^~~~~ [6] | 4D 4E [2] | 4A 4G [ 4E^^ 4D^^ ] 4C^~~ |",
  "0 0 4C 3B | 3A^~~~~ 4C^ 4E | 4D 4C^ 3B^~~ - 4C | 3A~~~ - - - | 0 0 0 0 ||"]
