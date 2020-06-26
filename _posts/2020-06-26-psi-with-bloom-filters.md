---
title: "Private set intersection with Bloom filters"
description: "In this post we’ll introduce Bloom filters and see how they can be used to improve data transfer efficiency in private set intersection."
category: tech
tags: [cryptography, private set intersection, bloom filter]
math: true
---

In the [last post][blogpost psi with ecdh] we saw how to build a private set intersection (PSI) protocol on top of elliptic curve Diffie-Hellman (ECDH). In this post we’ll introduce [Bloom filters][wiki bloom filter] and see how they can be used to improve data transfer efficiency.

## Recap of the PSI protocol using ECDH

For the full protocol, read the last blog post. Recall that a PSI protocol based on Diffie-Hellman (whether standard or ECDH) has an advantage over some PSI protocols (such as the one we saw previously [based on the Paillier cryptosystem][blogpost psi with paillier]) in that the amount of data transferred between client and server is proportional to the number of elements in the respective sets: we do not have to send a value for every element in the domain. This has the side effect that the size of the respective sets is leaked but we assume there are contexts where this is not sensitive information.

However, a common real world situation will involve relatively small sets on the client side and relatively large sets on the server side. For example, imagine an app can put you in touch with other users if they are contacts of yours, but you don’t want to just hand over all your contact information to the app and they don’t want to give you all their users’ emails. PSI could help you work out which of your contacts are already using the app without leaking any private information. In this case your contact list is likely in the hundreds, whereas the user base of the app could be in the millions. Even with PSI based on ECDH, that’s still a lot of data to transfer!

## Bloom filters

A Bloom filter is a data structure which we can construct from a set, and then we can ask it whether a particular element is present in the original set. The Bloom filter will tell us either "definitely not" or "probably" and the degree of confidence can be configured. The tradeoff here is confidence vs size: the more confidence you want, the more space (bits) your Bloom filter will require. Assuming that you don’t need absolute certainty though, Bloom filters provide an efficient way to transfer a set in situations where all that’s required is to check the presence of an element, rather than to retrieve data from it.

Here’s how it works:

1. Initialize a bit array of size $$m$$ with all $$0$$s.
1. Define a set of $$k$$ hash functions, each of which returns a position in the bit array.
1. To add an element to the filter, hash it with each of the hash functions to generate $$k$$ positions (which may or may not overlap). Set the bit at each of these positions in the filter to $$1$$.
1. To query whether an element is present in the set, hash the relevant element to generate $$k$$ positions. If any of the bits in the filter is $$0$$ then the element is definitely not present. If they are all $$1$$ then either the element is present in the set or those bits were all turned on by other elements by chance (a false positive).

The parameters $$m$$ and $$k$$ should be chosen with reference to the number of elements in the set $$n$$ as well as the desired false positive rate $$\varepsilon$$. The optimal number of bits $$m$$ for the bit array is $$-\frac{n\log_2 \varepsilon}{\ln 2}$$, which is roughly $$-1.44n\log_2 \varepsilon$$. Then the optimal number of hash functions $$k$$ is $$\frac{m}{n}\ln 2$$. (Note this all assumes that we know the size of the set in advance.)

As for hash functions, we want the output to be uniformly distributed across the bit array, and the outputs of the different hash functions to be independent of each other. If we want people to be unable to infer the presence of an element without querying for it directly, it is important that the hash function is cryptographically secure.

For example we could use SHA256 with a series of salts ($$0,1,...k-1$$), and give the output modulo the number of bits $$m$$. This will not be perfectly uniform across the positions of the bit array, but if the bit array is reasonably large the effect of the non-uniformity will be negligible.

## Adding a Bloom filter to the PSI protocol

As our PSI with ECDH protocol stands, the naïve way to incorporate a Bloom filter would be for Bob to store the twice point-multiplied values corresponding to Alice’s set in a Bloom filter, and send those back to her so that Alice can calculate the values corresponding to Bob’s set and then check for their presence in the filter. However, this doesn’t save us much: Bob still has to transfer a value for each element in his set, which is likely to be the larger set as discussed above. Even if it is a situation where Alice’s set is the larger one, she still has to transfer it to Bob once, as the saving is only in one direction.

Can we do better? We can, but we need to modify our protocol a bit. As mentioned in the previous post, with ECDH it is easy to reverse point multiplication if you hold the secret key. This enables the following updated protocol:

1. Alice and Bob agree on an elliptic curve $$E$$.
1. Alice randomly generates a private key $$a$$.
1. Alice repeatedly hashes each of the values in her original set until they are all generators of $$E$$. For example, she could iteratively apply SHA256 to each value until the output corresponds to the $$x$$-value of a point on the curve.
1. For each of these hashed values, Alice calculates $$G \times a$$ using point multiplication where $$G$$ is the corresponding point on the curve.
1. Alice sends her calculated values to Bob.
1. Bob randomly generates a private key $$b$$.
1. Bob repeatedly hashes each of the values in his original set until they are all generators of $$E$$ in the same way Alice did.
1. For each of these hashed values, Bob calculates $$G \times b$$ just like Alice did with her set and private key.
1. Bob creates a Bloom filter and adds each of these calculated values to the filter.
1. Bob calculates shared keys corresponding to each element in Alice’s original set by calculating $$G \times ab$$, i.e. by performing point multiplication on the points received from Alice using his private key $$b$$.
1. Bob sends the Bloom filter corresponding to his set ($$G \times b$$) to Alice, as well as the shared keys corresponding to the elements in Alice’s original set ($$G \times ab$$).
1. Alice calculates $$G \times b$$ for each element in her set by reversing point multiplication using her secret key $$a$$ (see below).
1. For each value corresponding to an element in her set, Alice queries the Bloom filter received from Bob to see if it’s present. The intersection consists of those elements present in her set which are also present in the Bloom filter.

How does reversing point multiplication work? Recall that multiplication of a point $$G$$ on an elliptic curve $$E$$ consists in repeatedly adding $$G$$ to itself as discussed [in a previous post][blogpost elliptic curves]. But if $$G$$ is a generator of $$E$$ (as in our case), then eventually this process of adding $$G$$ to itself returns to $$G$$ again. And we can know in advance how many times we have to add $$G$$ to itself before it returns to $$G$$: that number is the order of $$G$$ on $$E$$. So if Alice subtracts her private key $$a$$ from the order, then she will get a number $$a^{-1}$$, such that performing point multiplication using this number is equivalent to reversing point multiplication using $$a$$.

With this version of the protocol values corresponding to Alice’s (by assumption smaller) set are sent in both directions. However the big saving is that values corresponding to Bob’s set are stored in a Bloom filter and this is only sent in one direction.

By the end of the protocol, Bob only sees the values which Alice hashed and obscured using her private key ($$G \times a$$), while Alice only sees the Bloom filter Bob sent her as well as the values Bob calculated based on her own set ($$G \times a b$$). The Bloom filter contains the values which Bob hashed and obscured using his private key ($$G \times b$$), but even these cannot be retrieved if Bob used a cryptographically secure hash function to store them in the Bloom filter. Eve the eavesdropper also sees these values, and is in no better situation to derive sensitive information from them than either Alice or Bob.

## Extending the protocol

As with other variants of PSI based on Diffie-Hellman, this protocol can be extended to give Alice the size of the intersection without giving her the intersection itself. Bob simply shuffles the values corresponding to Alice’s set before returning them so Alice cannot link particular elements in her set to elements present in the Bloom filter. Likewise, I am unaware of any way to extend this protocol to give a boolean result ("intersection is empty" vs "intersection is not empty").

There are other kinds of filters which we could use. For example, [cuckoo filters][wiki cuckoo filter] are similar to Bloom filters but enable the deletion of elements from the filter, and may also be more space-efficient.

## Code

As usual, I have implemented this PSI protocol in [my learning repository][willclarktech privacy-implementations], and the usual warning applies...

**WARNING: This library is not recommended for production use. It was written for learning purposes only.**

This implementation uses the P-256 elliptic curve and the SHA256 hash function for both hashing to points on the elliptic curve and for storing in the Bloom filter. Here’s how the process looks using this implementation:

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
const response = server.revealIntersectionFilter(intermediateValues); // Server values are now transferred in a Bloom filter
const intersection = client.handleIntersectionFilterResponse(response); // [0, 20, 40]
```

## Limitations and advantages

The big advantage of using a Bloom filter is in efficiency of data transfer. This applies in either direction, but the updated protocol here enables substantial efficiency savings for use cases where the server set is significantly larger than the client set.

We already saw in the previous post that the main benefit of ECDH over standard Diffie-Hellman is in terms of efficiency. With this updated protocol we see an additional benefit of ECDH: the new protocol relies on it being easy for the client to run their one-way function in reverse using their private key. I.e. once Alice has $$G \times ab$$, she needs a way to find $$G \times b$$, by reversing the point multiplication process using her secret key $$a$$. This is easy because she can just perform point multiplication using a number related to $$a$$.

Compare this to standard Diffie-Hellman: in order to reverse $$g^{ab} \mod p$$, Alice would have to find the $$a$$th modular root of $$g^{ab}$$. There are some efficient techniques for this under certain circumstances (see e.g. [this paper][cho et al 2013] or [this lecture video][coursera lecture]), but they are somewhat complicated, may involve disjoint calculations depending on the properties of the root and the modulus, often involve a non-deterministic component, and may or may not involve solving a discrete logarithm.

As with the other PSI protocols based on Diffie-Hellman, the size of the client’s set is leaked to the server and any eavesdroppers. The size of the server’s set is not leaked directly, but anyone who can see the Bloom filter built from that set will be able to estimate the size of the server’s set based on the number of bits set to $$1$$, since the more elements in the filter, the more bits get set to $$1$$.

## Summary

In this post we have seen how to use Bloom filters to improve our PSI protocol based on ECDH, by reducing the amount of data which needs to be transferred from server to client. This is the approach that we have taken in the [OpenMined PSI library][openmined psi], which is an open-source library with bindings for C++, JavaScript, Go, Python, and more to come.

## Links

- [Original paper on Bloom Filters][bloom 1970]
- [Node.js implementation][willclarktech implementation] from my privacy learning repository
- [OpenMined website][openmined website]

[wiki bloom filter]: https://en.wikipedia.org/wiki/Bloom_filter
[blogpost psi with ecdh]: /tech/2020/06/19/psi-with-ecdh.html
[blogpost psi with paillier]: /tech/2020/05/18/psi-with-paillier.html
[blogpost elliptic curves]: /tech/2020/06/12/elliptic-curves-diffie-hellman.html
[wiki cuckoo filter]: https://en.wikipedia.org/wiki/Cuckoo_filter
[willclarktech privacy-implementations]: https://github.com/willclarktech/privacy-implementations
[cho et al 2013]: https://eprint.iacr.org/2013/041.pdf
[coursera lecture]: https://www.coursera.org/lecture/crypto/modular-e-th-roots-fjRVO
[bloom 1970]: https://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.641.9096
[willclarktech implementation]: https://github.com/willclarktech/privacy-implementations/tree/b87ff3a/src/private-set-intersection/elliptic-curve-diffie-hellman
[openmined psi]: https://github.com/OpenMined/PSI
[openmined website]: https://openmined.org/
