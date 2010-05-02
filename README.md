Lemmachine
==========

Lemmachine is a REST'ful web framework that makes it easy to get HTTP right by exposing users to overridable hooks with sane defaults. The main architecture is a copy of Erlang-based [Webmachine](http://webmachine.basho.com), which is currently the best documentation reference (for hooks & general design).

Lemmachine stands out from the dynamically typed Webmachine by being written in dependently typed
[Agda](http://wiki.portal.chalmers.se/agda/pmwiki.php). The goal of the project is to show the advantages gained from compositional testing by taking advantage of proofs being inherently compositional. See [proofs](http://github.com/larrytheliquid/Lemmachine/blob/master/Lemmachine/Proofs.agda) for examples of universally quantified proofs (tests over all possible input values) written against the [default resource](http://github.com/larrytheliquid/Lemmachine/blob/master/Lemmachine/Resource/Default.agda), which does not override any hooks.

When a user implements their own resource, they can write simple lemmas ("unit tests") against the resource's hooks, but then literally reuse those lemmas to write more complex proofs ("integration tests"). For examples see some reuse of [lemmas](http://github.com/larrytheliquid/Lemmachine/blob/master/Lemmachine/Lemmas.agda) in [proofs](http://github.com/larrytheliquid/Lemmachine/blob/master/Lemmachine/Proofs.agda).

The big goal is to show that in service oriented architectures, proofs of individual [middlewares](http://github.com/larrytheliquid/Lemmachine/blob/master/Lemmachine/Utils.agda) can themselves be reused to write cross-service proofs (even higher level "integration tests") for a consumer application that mounts those middlewares. See [this post](http://vision-media.ca/resources/ruby/ruby-rack-middleware-tutorial) for what is meant by middleware.

Another goal is for Lemmachine to come with proofs against the default resource (as it already does). Any hooks the user does not override can be given to the user for free by the framework! Anything that is overridden can generate proofs parameterized only by the extra information the user would need to provide. This would be a major boost in productivity compared to traditional languages whose libraries cannot come with tests for the user that have language-level semantics for real proposition reuse!

Lemmachine currently uses the Haskell [Hack](http://github.com/nfjinjing/hack) abstraction so it can run on several Haskell webservers. Because Agda compiles to Haskell and has an FFI, existing Haskell code can be integrated quite easily.

## Status ##

This project is still very much an early-stage work in progress, without guarantees for API stability. It currently only renders response statuses (not headers or body). Lemmas and proofs exist for the status resolution, and now there is a real runner hardcoded against the default resource!

## Setup ##

[Grab Haskell](http://hackage.haskell.org/platform) if you don't already have it installed.

    cabal update
    cabal install hack hack-handler-happstack Agda-executable

Add Cabal binaries to your `PATH` in `~/.profile`:
    export PATH=~/.cabal/bin:$PATH 

Make sure you have Agda version `2.2.6`:
    agda --version

## Development ##

Get [Emacs to work with Agda](http://wiki.portal.chalmers.se/agda/pmwiki.php?n=Main.README-2-2-6).

[Examples](http://wiki.portal.chalmers.se/agda/pmwiki.php?n=Main.QuickGuideToEditingTypeCheckingAndCompilingAgdaCode) of how to use `agda-mode`.

We use a vendored modified Agda stdlib, so in Emacs:
    M-x customize group
    agda2

Then add this to `Agda2 Include Dirs`:
    ./vendor/stdlib/src

## Running ##

Lemmachine currently supports resolving HTTP status codes (resolving
headers & body will come later).

Run the following to see this in action for [Lemmachine.Resource.Default](http://github.com/larrytheliquid/Lemmachine/blob/master/Lemmachine/Resource/Default.agda):
    agda -c -i . -i ./vendor/stdlib/src Lemmachine/Runner.agda
    ./Runner

In a separate terminal, see a `200` response:
    curl -X GET -H "Accept: text/html" -i http://localhost:3000 && echo

... compared to a `406` due to requesting an unsupported `text/xml` media type:
    curl -X GET -H "Accept: text/xml" -i http://localhost:3000 && echo

... compared to a `405` due to requesting an unsupported `POST` method:
    curl -X POST -H "Accept: text/html" -i http://localhost:3000 && echo

All of this is just default behavior and can be overridden by defining appropriate hook methods.
