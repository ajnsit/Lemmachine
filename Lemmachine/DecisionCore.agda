module Lemmachine.DecisionCore where
open import Lemmachine.Resource
open import Lemmachine.Request
open import Lemmachine.Status
open import Lemmachine.Utils
open import Data.Bool
open import Data.Nat
open import Data.String
open import Relation.Binary
open import Relation.Binary.PropositionalEquality
open import Data.Maybe
open import Data.List
open import Data.Product

postulate D4 : Request → Status

C3+C4 : Request → Status
C3+C4 r with detect "Accept" (Request.headers r)
... | nothing = D4 r
... | just contentType with detect contentType (contentTypesProvided r)
... | just _ = D4 r
... | nothing = NotAcceptable

B3 : Request → Status
B3 r with Request.method r
... | OPTIONS = OK
... | _       = C3+C4 r

B4 : Request → Status
B4 r with validEntityLength r
... | true  = B3 r
... | false = RequestEntityTooLarge

B5 : Request → Status
B5 r with knownContentType r
... | true  = B4 r
... | false = UnsupportedMediaType

B6 : Request → Status
B6 r with validContentHeaders r
... | true  = B5 r
... | false = NotImplemented

B7 : Request → Status
B7 r with forbidden r
... | true  = Forbidden
... | false = B6 r

B8 : Request → Status
B8 r with isAuthorized r
... | true  = B7 r
... | false = Unauthorized

B9 : Request → Status
B9 r with malformedRequest r
... | true  = BadRequest
... | false = B8 r

B10 : Request → Status
B10 r with any (eqMethod (Request.method r))
               (allowedMethods r)
... | true  = B9 r
... | false = MethodNotAllowed

B11 : Request → Status
B11 r with uriTooLong r
... | true  = RequestURItooLong
... | false = B10 r

B12 : Request → Status
B12 r with any (eqMethod (Request.method r))
               (knownMethods r)
... | true  = B11 r 
... | false = NotImplemented

B13 : Request → Status
B13 r with serviceAvailable r 
... | true  = B12 r 
... | false = ServiceUnavailable

decide : Request → Status
decide r = B13 r
