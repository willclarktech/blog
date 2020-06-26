---
title: "Private set intersection with ECDH"
description: "In this post we’ll see how a private set intersection protocol can be built on top of ECDH."
category: tech
tags:
  [
    diffie-hellman,
    cryptography,
    elliptic curves,
    private set intersection,
    ecdh,
  ]
math: true
---

In the [last post][ecdh blogpost] we saw how elliptic curve point multiplication offers an alternative basis for key exchange in a Diffie-Hellman protocol. We [saw previously][psi with diffie-hellman blogpost] how the standard Diffie-Hellman protocol can be used as the foundation for a private set intersection (PSI) technique. In this post, we’ll see how to do the same thing based on elliptic curve Diffie-Hellman (ECDH) instead.

## The protocol

Here’s a recap of the goal of PSI from last time:

> PSI is where each of two parties has a set of elements, and one or both of them want(s) to discover the intersection between those sets (a) without revealing anything other than the intersection to each other, and (b) without revealing anything sensitive about their sets to an eavesdropper.

We can use the same basic process as last time too:

> Suppose Alice (the client) and Bob (the server) each has a set of elements from some domain and Alice wants to discover the intersection of her set with Bob’s set, but Alice doesn't want to reveal her set to Bob and Bob doesn’t want to reveal what’s in his set to Alice, besides the intersection. To build a PSI protocol on top of Diffie-Hellman, we essentially generate two sets of shared keys, one key for each element in the two sets. So any shared key which is found in both of these sets indicates that the corresponding element is a member of both parties’ original sets.

Here is the updated protocol for ECDH:

1. Alice and Bob agree on an elliptic curve $$E$$.
1. Alice randomly generates a private key $$a$$.
1. Alice repeatedly hashes each of the values in her original set until they are all generators of $$E$$. For example, she could iteratively apply SHA256 to each value until the output corresponds to the $$x$$-value of a point on the curve.
1. For each of these hashed values, Alice calculates $$G \times a$$ using point multiplication where $$G$$ is the corresponding point on the curve.
1. Alice sends her calculated values to Bob.
1. Bob randomly generates a private key $$b$$.
1. Bob repeatedly hashes each of the values in his original set until they are all generators of $$E$$ in the same way Alice did.
1. For each of these hashed values, Bob calculates $$G \times b$$ just like Alice did with her set and private key.
1. Bob calculates shared keys corresponding to each element in Alice’s original set by calculating $$G \times ab$$, i.e. by performing point multiplication on the points received from Alice using his private key $$b$$.
1. Bob sends his calculated values ($$G \times b$$) to Alice, as well as the calculated shared keys corresponding to the elements in Alice’s original set.
1. Alice calculates the shared keys corresponding to each element in Bob’s original set by calculating $$G \times ba$$, i.e. by performing point multiplication on the points received from Bob using her private key $$a$$.
1. Alice compares the shared keys calculated from the elements in her own original set with the shared keys calculated using Bob’s elements. The intersection consists of those elements in Alice’s original set whose shared key can also be found in the set of shared keys calculated from the elements in Bob’s original set.

By the end of the protocol, Bob only sees the values which Alice hashed and obscured using her private key ($$G \times a$$), while Alice only sees the similarly obscured values from Bob’s set, as well as her own obscured values multiplied by Bob’s secret ($$G \times ab$$). Eve the eavesdropper also sees these values, but since we assume that it is difficult to reverse point multiplication on elliptic curves, she is unable to extract the original elements from either set. They are also hidden behind a hash function for additional security if a cryptographically secure hash function is used. The same applies for Alice and Bob, except that Alice obviously learns the intersection.

As with PSI using standard Diffie-Hellman, the "shared keys" are not really keys at all; they are only used by Alice for comparison.

## Extending the protocol

As with PSI based on standard Diffie-Hellman, this protocol can be extended to give Alice the size of the intersection but not the intersection itself. Like before, Bob simply shuffles the values he calculates corresponding to Alice’s set before returning them to Alice, so she is unable to link matches to specific elements in her own set.

As far as I’m aware it is not possible to develop this into a protocol which only gives Alice a boolean result ("intersection is empty" or "intersection is not empty") as it was with [PSI based on the Paillier cryptosystem][psi with paillier blogpost].

## Code

As usual, I have implemented this PSI protocol in [my learning repository][willclarktech privacy-implementations], and the usual warning applies...

**WARNING: This library is not recommended for production use. It was written for learning purposes only.**

This implementation uses the P-256 elliptic curve and the SHA256 hash function. Here’s how the process looks using this implementation:

```js
const {
  Client,
  Server,
} = require("./build/private-set-intersection/elliptic-curve-diffie-hellman");

const clientSet = new Set([0, 5, 10, 15, 20, 25, 30, 35, 40, 45]);
const serverSet = new Set([0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48]);

const client = new Client(clientSet);
const server = new Server(serverSet);

const intermediateValues = client.prepareIntermediateValues();
const response = server.revealIntersection(intermediateValues);
const intersection = client.handleIntersectionResponse(response); // [0, 20, 40]
```

## Limitations and advantages

One advantage of this protocol over PSI with standard Diffie-Hellman is efficiency. Just as with key exchange, the same level of security can be achieved with smaller keys, thanks to the power of elliptic curves. We saw in the previous post how my implementation was extremely slow to generate keys with secure lengths. By contrast, with no focus on performance and using a [popular elliptic curve library][github elliptic], all the calculations performed in the code section above are very fast.

Another advantage—which we will explore in a future post—is the ease of reversing point multiplication using a private key, relative to reversing modular exponentiation. This will enable us to improve the efficiency of data transfer.

As with PSI based on standard Diffie-Hellman, a weakness of this approach is that the size of each set is leaked to Eve the eavesdropper (as well as to Alice and Bob). So for contexts where this information is sensitive, another approach such as PSI with Paillier may be the way to go.

This approach also assumes that servers are honest, and if the domain is too small then a malicious client can extract the server’s full set through a series of targeted requests (just like the other approaches we’ve looked at so far).

## Summary

In this post we have seen how the PSI protocol based on standard Diffie-Hellman can be adapted to use ECDH instead. As with key exchange, one advantage is efficiency. We can also improve data transfer efficiency using data structures such as Bloom filters as we’ll see in the next post.

## Links

- [Node.js implementation][willclarktech implementation] from my privacy learning repository

[ecdh blogpost]: /tech/2020/06/12/elliptic-curves-diffie-hellman.html
[psi with diffie-hellman blogpost]: /tech/2020/05/26/psi-with-diffie-hellman.html
[psi with paillier blogpost]: /tech/2020/05/18/psi-with-paillier.html
[willclarktech privacy-implementations]: https://github.com/willclarktech/privacy-implementations
[github elliptic]: https://github.com/indutny/elliptic
[willclarktech implementation]: https://github.com/willclarktech/privacy-implementations/tree/b87ff3a/src/private-set-intersection/elliptic-curve-diffie-hellman
