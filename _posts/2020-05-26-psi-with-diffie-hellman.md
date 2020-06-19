---
title: "Private set intersection with Diffie-Hellman"
description: "In this post we’ll see how a private set intersection protocol can be built on top of the Diffie-Hellman key exchange protocol."
category: tech
tags: [diffie-hellman, cryptography, private set intersection]
math: true
---

In the [previous post][diffie-hellman blogpost] we looked at the Diffie-Hellman key exchange protocol, which two parties can use to agree upon a secret key without an eavesdropper discovering what that key is. We saw [previously][psi paillier blogpost] how a private set intersection (PSI) protocol could be built on top of the [Paillier cryptosystem][paillier blogpost]. In this post, we’ll see how to do the same thing based on Diffie-Hellman instead.

## The protocol

As a reminder, PSI is where each of two parties has a set of elements, and one or both of them want(s) to discover the intersection between those sets (a) without revealing anything other than the intersection to each other, and (b) without revealing anything sensitive about their sets to an eavesdropper.

Suppose Alice (the client) and Bob (the server) each has a set of elements from some domain and Alice wants to discover the intersection of her set with Bob’s set, but Alice doesn't want to reveal her set to Bob and Bob doesn’t want to reveal what’s in his set to Alice, besides the intersection. To build a PSI protocol on top of Diffie-Hellman, we essentially generate two sets of shared keys, one key for each element in the two sets. So any shared key which is found in both of these sets indicates that the corresponding element is a member of both parties’ original sets. I’ll clarify a couple of points in a moment, but for now here’s the basic process:

1. Alice and Bob agree on a large prime $$p$$.
1. Alice randomly generates a private key $$a$$.
1. Alice repeatedly hashes each of the values in her original set until they are all primitive roots modulo $$p$$. (See below.)
1. For each of these hashed values, Alice calculates $$g^a \mod p$$ where $$g$$ is the hashed value.
1. Alice sends $$p$$ and her calculated values to Bob.
1. Bob randomly generates a private key $$b$$.
1. Bob repeatedly hashes each of the values in his original set until they are all primitive roots modulo $$p$$.
1. For each of these hashed values, Bob calculates $$g^b \mod p$$) where $$g$$ is the hashed value.
1. Bob calculates shared keys corresponding to each element in Alice’s original set by raising the values received from Alice to the power of his private key, i.e. $$g^{ab} \mod p$$ for each hashed value $$g$$.
1. Bob sends his calculated values ($$g^b \mod p$$) to Alice, as well as the calculated shared keys corresponding to the elements in Alice’s original set.
1. Alice calculates the shared keys corresponding to each element in Bob’s original set by raising the values received from Bob to the power of her private key, i.e. $$g^{ba} = g^{ab} \mod p$$ for each of Bob’s hashed values, $$g$$.
1. Alice compares the shared keys calculated from the elements in her own original set with the shared keys calculated using Bob’s elements. The intersection consists of those elements in Alice’s original set whose shared key can also be found in the set of shared keys calculated from the elements in Bob’s original set.

Note that the hashing in steps 3 and 7 is necessary because the Diffie-Hellman protocol requires the base value $$g$$ to be a primitive root modulo $$p$$.

In the end Bob only sees the values Alice hashed and obscured using her private key ($$g^a \mod p$$), while Alice only sees the similarly obscured values from Bob’s set, as well as her own obscured values raised to the power of Bob’s private key ($$g^{ab} \mod p$$). Of course Eve the eavesdropper also sees these values. When using Diffie-Hellman for key exchange, these shared keys are sensitive, but in our PSI protocol they are also visible to Eve. That’s fine though, because they aren’t then used for encryption, just comparison. The important thing is that without Alice’s private key (or Bob’s), Eve cannot reconstruct either of their sets (the sensitive data in this situation) or find out anything about their intersection (because she only sees one set of shared keys).

## Extending the protocol

As with PSI based on the Paillier cryptosystem, this protocol can be extended to reveal only the intersection _size_ to the client. In order to determine the intersection, it is important that Bob returns the shared keys corresponding to Alice’s values in the same order he receives them, so that Alice knows which elements in her set are the corresponding ones. However, if Bob shuffles those shared keys before returning them to Alice, Alice will not be able to connect the shared keys back to specific elements, though she will still be able to see how many elements are common to the two sets. One simple way for Bob to do this would be for him to sort the shared keys numerically, since without his secret key the values should appear uniform.

It’s not possible (as far as I’m aware) to develop this into a protocol which just gives Alice a boolean answer “intersection is empty” or “intersection is not empty”, as we were able to with the Paillier-based PSI protocol.

## Code

As usual, I have implemented this PSI protocol in [my learning repository][willclarktech privacy-implementations], and the usual warning applies...

**WARNING: This library is not recommended for production use. It was written for learning purposes only.**

Here’s how to use that implementation:

```js
const {
  Client,
  Server,
} = require("./build/private-set-intersection/diffie-hellman");

const bitLength = 8;
const clientSet = new Set([0, 5, 10, 15, 20, 25, 30, 35, 40, 45]);
const serverSet = new Set([0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48]);

const server = new Server(serverSet, { bitLength }); // Slow! Generating keys.
const { p } = server;
const client = new Client(clientSet, { bitLength, p });

const intermediateValues = client.prepareIntermediateValues();
const response = server.revealIntersection(intermediateValues);
const intersection = client.handleIntersectionResponse(response); // [0, 20, 40]
```

## Limitations and advantages

When we looked at PSI based on the Paillier cryptosystem, we saw there were several limitations. Some of those limitations also apply to this Diffie-Hellman PSI protocol, including the assumption that the server and client are honest, and even with the size-only protocol a malicious client could derive the full server set if the domain is small enough.

An additional weakness is that the size of each party’s set is leaked to the other party (and any eavesdroppers), because only values relating to each element are sent to the other party. However, the flipside of this is that this protocol is much more practical for large domains because we do not need to perform calculations on values not in either set, and do not need to transfer them across a connection either.

My implementation is also very slow to initialize parties, hence the small bit length in the code example! This can probably be sped up somewhat with a better implementation focused more on performance, but a problematic calculation is introduced which is necessary for steps 3 and 7 of the protocol (hashing numbers until they are primitive roots).

## Summary

In this post we have seen how to develop a PSI protocol on top of the Diffie-Hellman key exchange protocol. By sacrificing a little privacy (leaking the size of each party’s set), we gain a huge efficiency advantage in comparison to the PSI protocol based on the Paillier cryptosystem. In the next post we’ll introduce elliptic curves and ECDH, which can be used to improve efficiency further and sidestep the problematic calculation.

## Links

- [Node.js implementation][willclarktech implementation] from my privacy learning repository

[diffie-hellman blogpost]: /tech/2020/05/22/diffie-hellman-key-exchange.html
[psi paillier blogpost]: /tech/2020/05/18/psi-with-paillier.html
[paillier blogpost]: /tech/2020/05/15/paillier-cryptosystem.html
[willclarktech privacy-implementations]: https://github.com/willclarktech/privacy-implementations
[willclarktech implementation]: https://github.com/willclarktech/privacy-implementations/tree/a7797d7/src/private-set-intersection/diffie-hellman
