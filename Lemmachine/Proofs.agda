module Lemmachine.Proofs where
open import Lemmachine.Lemmas
open import Lemmachine.Request
open import Lemmachine.Status
open import Lemmachine.Resource
open import Lemmachine.DecisionCore
open import Lemmachine.Utils
open import Data.Bool
open import Data.List
open import Data.List.Any hiding (any)
open Membership-≡
open import Relation.Binary.PropositionalEquality
open import Data.Maybe
open import Data.Product
open import Data.Function using (const)

serviceUnavailable : ∀ r → resolve (configure [ serviceAvailable ⇒ const false ]) r ≡ ServiceUnavailable
serviceUnavailable _ = refl

unknownMethod : ∀ r → resolve (configure [ knownMethods ⇒ const [] ]) r ≡ NotImplemented
unknownMethod _ = refl

tooLongConfig = configure [ uriTooLong ⇒ const true ]
requestURItooLong : ∀ r → Request.method r ∈ Config.knownMethods tooLongConfig r
                        → resolve tooLongConfig r ≡ RequestURItooLong
requestURItooLong r p with methodIsKnown tooLongConfig r p
... | p₂ rewrite p₂ = refl

notAllowedConfig = configure [ allowedMethods ⇒ const [] ]
disallowedMethod : ∀ r → Request.method r ∈ Config.knownMethods notAllowedConfig r
                       → resolve notAllowedConfig r ≡ MethodNotAllowed
disallowedMethod r p with methodIsKnown notAllowedConfig r p
... | p₂ rewrite p₂ = refl

malformedConfig = configure [ malformedRequest ⇒ const true ]
badRequest : ∀ r → Request.method r ∈ Config.knownMethods malformedConfig r
                 → Request.method r ∈ Config.allowedMethods malformedConfig r
                 → resolve malformedConfig r ≡ BadRequest
badRequest r p p₂ with methodIsKnown malformedConfig r p | methodIsAllowed malformedConfig r p₂
... | p₃ | p₄ rewrite p₃ | p₄ = refl

unauthorizedConfig = configure [ isAuthorized ⇒ const false ]
unauthorized : ∀ r → Request.method r ∈ Config.knownMethods unauthorizedConfig r
                   → Request.method r ∈ Config.allowedMethods unauthorizedConfig r
                   → resolve unauthorizedConfig r ≡ Unauthorized
unauthorized r p p₂ with methodIsKnown unauthorizedConfig r p | methodIsAllowed unauthorizedConfig r p₂
... | p₃ | p₄ rewrite p₃ | p₄ = refl

forbiddenConfig = configure [ forbidden ⇒ const true ]
lem-forbidden : ∀ r → Request.method r ∈ Config.knownMethods forbiddenConfig r
                    → Request.method r ∈ Config.allowedMethods forbiddenConfig r
                    → resolve forbiddenConfig r ≡ Forbidden
lem-forbidden r p p₂ with methodIsKnown forbiddenConfig r p | methodIsAllowed forbiddenConfig r p₂
... | p₃ | p₄ rewrite p₃ | p₄ = refl

invalidContentHeadersConfig = configure [ validContentHeaders ⇒ const false ]
invalidContentHeaders : ∀ r → Request.method r ∈ Config.knownMethods invalidContentHeadersConfig r
                            → Request.method r ∈ Config.allowedMethods invalidContentHeadersConfig r
                            → resolve invalidContentHeadersConfig r ≡ NotImplemented
invalidContentHeaders r p p₂ with methodIsKnown invalidContentHeadersConfig r p | methodIsAllowed invalidContentHeadersConfig r p₂
... | p₃ | p₄ rewrite p₃ | p₄ = refl

unknownContentTypeConfig = configure [ knownContentType ⇒ const false ]
unsupportedMediaType : ∀ r → Request.method r ∈ Config.knownMethods unknownContentTypeConfig r
                           → Request.method r ∈ Config.allowedMethods unknownContentTypeConfig r
                           → resolve unknownContentTypeConfig r ≡ UnsupportedMediaType
unsupportedMediaType r p p₂ with methodIsKnown unknownContentTypeConfig r p | methodIsAllowed unknownContentTypeConfig r p₂
... | p₃ | p₄ rewrite p₃ | p₄ = refl

invalidEntityLengthConfig = configure [ validEntityLength ⇒ const false ]
invalidEntityLength : ∀ r → Request.method r ∈ Config.knownMethods invalidEntityLengthConfig r
                          → Request.method r ∈ Config.allowedMethods invalidEntityLengthConfig r
                          → resolve invalidEntityLengthConfig r ≡ RequestEntityTooLarge
invalidEntityLength r p p₂ with methodIsKnown invalidEntityLengthConfig r p | methodIsAllowed invalidEntityLengthConfig r p₂
... | p₃ | p₄ rewrite p₃ | p₄ = refl

optionsSuccess : ∀ r → Request.method r ≡ OPTIONS → B3 (configure []) r ≡ OK
optionsSuccess _ p rewrite p = refl

preconditionFailed : ∀ r → fetch "If-Match" (Request.headers r) ≡ just "*"
                         → H7 (configure []) r ≡ PreconditionFailed
preconditionFailed r p with fetch "If-Match" (Request.headers r) | p
... | ._ | refl = refl
