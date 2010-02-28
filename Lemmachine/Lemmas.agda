module Lemmachine.Lemmas where
open import Lemmachine.Request
open import Lemmachine.Status
open import Lemmachine.Utils
open import Data.Bool
open import Data.List
open import Data.Maybe
open import Relation.Binary.PropositionalEquality
open import Lemmachine.Resource
import Lemmachine.DecisionCore
open Lemmachine.DecisionCore default

serviceUnavailable : ∀ {r} → B13 (λ _ → false) r ≡ ServiceUnavailable
serviceUnavailable = refl

unknownMethod : ∀ {r} → B12 (λ _ → []) r ≡ NotImplemented
unknownMethod = refl

requestURItooLong : ∀ {r} → B11 (λ _ → true) r ≡ RequestURItooLong
requestURItooLong = refl

disallowedMethod : ∀ {r} → B10 (λ _ → []) r ≡ MethodNotAllowed
disallowedMethod = refl

badRequest : ∀ {r} → B9 (λ _ → true) r ≡ BadRequest
badRequest = refl

unauthorized : ∀ {r} → B8 (λ _ → false) r ≡ Unauthorized
unauthorized = refl

forbidden : ∀ {r} → B7 (λ _ → true) r ≡ Forbidden
forbidden = refl

invalidContentHeaders : ∀ {r} → B6 (λ _ → false) r ≡ NotImplemented
invalidContentHeaders = refl

unsupportedMediaType : ∀ {r} → B5 (λ _ → false) r ≡ UnsupportedMediaType
unsupportedMediaType = refl

invalidEntityLength : ∀ {r} → B4 (λ _ → false) r ≡ RequestEntityTooLarge
invalidEntityLength = refl

optionsSuccess : ∀ {r}(p : Request.method r ≡ OPTIONS) → B3 r ≡ OK
optionsSuccess p rewrite p = refl

preconditionFailed : ∀ {r}(p : fetch "If-Match" (Request.headers r) ≡ just "*") → H7 r ≡ PreconditionFailed
preconditionFailed {r} p with fetch "If-Match" (Request.headers r) | p
... | ._ | refl = refl
