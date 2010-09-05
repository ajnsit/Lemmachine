module Lemmachine.Format.Response where
open import Data.Nat
open import Data.Maybe
open import Data.Product
open import Lemmachine.Data hiding ([_])
open import Lemmachine.HTTP
open import Lemmachine.Format

Simple-Format =
  Slurp (Base CHAR)

Shared-Headers-Format : Format
Shared-Headers-Format =
  Required-Header Date >>-
  Optional-Header Pragma >>-
  Optional-Header Server >>-
  End

HEAD-Format : Format
HEAD-Format =
  Shared-Headers-Format

GET-Format = HEAD-Format
POST-Format =
  Shared-Headers-Format

Method-Format : Method → Format
Method-Format GET  = GET-Format
Method-Format HEAD = HEAD-Format
Method-Format POST = POST-Format

Location-Format : Method → Code → Format
Location-Format _ 300-Multiple-Choices  = Optional-Header Location
Location-Format _ 301-Moved-Permanently = Required-Header Location
Location-Format _ 302-Moved-Temporarily = Required-Header Location
Location-Format _ _                     = Optional-Header Location

WWW-Authenticate-Format : Code → Format
WWW-Authenticate-Format 401-Unauthorized = Required-Header WWW-Authenticate
WWW-Authenticate-Format _                = End

Entity-Body-Format : Format → Method → Code → Format
Entity-Body-Format x _    204-No-Content   = x >>- Headers-End >> End
Entity-Body-Format x _    304-Not-Modified = x >>- Headers-End >> End
Entity-Body-Format x m c =
  Optional-Header Allow >>-
  Optional-Header Content-Encoding >>-
  Required-Header Content-Length >>= λ c-l →
  Required-Header Content-Type >>-
  Optional-Header Expires >>-
  Optional-Header Last-Modified >>-
  x >>-
  Headers-End >>
  f m c (proj₁ c-l) (proj₁ (proj₂ c-l))
  where
  f : Method → Code → (s : Single Content-Length) → Header-Value (proj s) → Format
  f HEAD _                         _           _    = End
  f _    201-Created               (single ._) zero = Fail
  f _    202-Accepted              (single ._) zero = Fail
  f _    300-Multiple-Choices      (single ._) zero = Fail
  f _    301-Moved-Permanently     (single ._) zero = Fail
  f _    302-Moved-Temporarily     (single ._) zero = Fail
  f _    400-Bad-Request           (single ._) zero = Fail
  f _    401-Unauthorized          (single ._) zero = Fail
  f _    404-Not-Found             (single ._) zero = Fail
  f _    500-Internal-Server-Error (single ._) zero = Fail
  f _    501-Not-Implemented       (single ._) zero = Fail
  f _    502-Bad-Gateway           (single ._) zero = Fail
  f _    503-Service-Unavailable   (single ._) zero = Fail
  f _    _                         (single ._) n    = Base (STR n)

Full-Format : Method → Format
Full-Format m =
  Base VERSION >>-
  SP >>
  Base CODE >>= λ c →
  POST-Required-For-Created m c >>
  SP >>
  Base REASON-PHRASE >>-
  CRLF >>
  Location-Format m c >>-
  WWW-Authenticate-Format c >>-
  Entity-Body-Format (Method-Format m) m c

  where

  POST-Required-For-Created : Method → Code → Format
  POST-Required-For-Created GET  201-Created = Fail
  POST-Required-For-Created HEAD 201-Created = Fail
  POST-Required-For-Created _    _           = End

Response-Format : Maybe Method → Format
Response-Format nothing  = Simple-Format
Response-Format (just m) = Full-Format m
