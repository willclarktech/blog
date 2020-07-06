---
title: "Diffie-Hellman Key Exchange"
description: "This post introduces the Diffie-Hellman key exchange protocol."
category: tech
tags: [diffie-hellman, cryptography, key exchange]
math: true
---

This post introduces the [Diffie-Hellman key exchange protocol][diffie-hellman wiki]. In the [previous post][psi paillier blogpost] we saw how to build a private set intersection (PSI) protocol on top of the [Paillier cryptosystem][paillier cryptosystem blogpost]. We can also build a PSI protocol on top of the Diffie-Hellman key exchange protocol, as we’ll see next time.

## The problem

Alice and Bob want to send encrypted messages to each other using a [symmetric encryption scheme][symmetric encryption wiki], so they need a shared secret key for encryption and decryption. How do they agree on a secret key without revealing it to Eve who is eavesdropping on all their communications?

## The solution

The solution to the problem is to find two secret-based one-way functions whose composition is commutative. Let’s break this down...

- _Secret-based_ means that in order to apply the function to an input it is necessary to know a secret parameter.
- A _one-way function_ is a function for which it is easy to compute the output given an input value, but hard to compute the input given an output value. A good example would be a cryptographic hash function which uses a salt as a secret parameter.
- _Function composition_ is where you combine two or more functions into a single function, by applying each function to the output of the previous function. For example, suppose you had two functions, $$addFive(x) = x + 5$$ and $$multiplyByThree(x) = x \times 3$$. You could compose a new function $$addFiveThenMultiplyByThree(x) = multiplyByThree(addFive(x))$$ out of those.
- _Commutative_ means that the order does not matter, so in the context of function composition it means it does not matter which function you apply first. The example above is not commutative because the order matters: adding 5 then multiplying by 3 is not the same thing as multiplying by 3 then adding 5.

Note that cryptographic hash functions with secret salts, although one-way, generally do not meet the requirement because their composition is not commutative: $$SHA256(secret_1 \Vert SHA256(secret_2 \Vert input))$$ is not the same as $$SHA256(secret_2 \Vert SHA256(secret_1 \Vert input))$$.

The original proposal from Diffie and Hellman is to use modular exponentiation as detailed below. This is because it is easy to compute $$g^e \mod p$$ but difficult to compute the values of $$g$$ and $$e$$ given only the output and the modulus $$p$$. So if you pick two secret exponents $$a$$ and $$b$$ you get two one-way functions: $$f_1(x) = x^a \mod p$$ and $$f_2(x) = x^b \mod p$$. Moreover, the composition of these functions is commutative because $$(g^a)^b = (g^b)^a \mod p$$.

## The protocol

1. Alice randomly generates a private key $$a$$, and picks a large prime $$p$$ and a number $$g$$, which is a [primitive root][primitive root wiki] modulo $$p$$.
1. Alice calculates $$A = g^a \mod p$$.
1. Alice sends $$p$$, $$g$$, and the calculated value $$A$$ to Bob.
1. Bob randomly generates a private key $$b$$.
1. Bob calculates $$g^{ab} \mod p$$ by calculating $$A^b \mod p$$.
1. Bob calculates $$B = g^b \mod p$$.
1. Bob sends the calculated value $$B$$ back to Alice.
1. Alice calculates $$g^{ab} \mod p$$ by calculating $$B^a \mod p$$.

Alice and Bob now share a secret key $$g^{ab} \mod p$$. Eve the eavesdropper has seen only $$g$$, $$p$$, $$A$$, and $$B$$. She is unable to derive the value of $$a$$ from $$A$$ or $$b$$ from $$B$$ efficiently without solving the [discrete logarithm problem][discrete logarithm wiki]. And without either of those values she is unable to calculate the secret key.

## Code

As usual, I have implemented the Diffie-Hellman key exchange protocol in my [learning repository][willclarktech privacy-implementations], and the usual warning applies:

**WARNING: This library is not recommended for production use. It was written for learning purposes only.**

```js
const diffieHellman = require("./build/cryptosystem/diffie-hellman");

const alice = new diffieHellman.Party(); // Slow! Finding appropriate prime numbers.
const { g, p } = alice;
const bob = new diffieHellman.Party({ g, p });

const aliceIntermediateValue = alice.raise(g);
const bobIntermediateValue = bob.raise(g);

const aliceSecret = alice.raise(bobIntermediateValue);
const bobSecret = bob.raise(aliceIntermediateValue); // Same as aliceSecret
```

## Summary

In this post we’ve seen how the Diffie-Hellman key exchange protocol allows two parties to agree on a single secret without an eavesdropper discovering what it is. Also note that Alice and Bob do not reveal their respective private keys to each other. This is an important fact, as we’ll see in the next post, where we build a PSI protocol on top of this.

## Links

- [Original paper][diffie-hellman 1976]
- [Node.js implementation][willclarktech implementation] from my privacy learning repository

[diffie-hellman wiki]: https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
[psi paillier blogpost]: /tech/2020/05/18/psi-with-paillier.html
[paillier cryptosystem blogpost]: /tech/2020/05/15/paillier-cryptosystem.html
[symmetric encryption wiki]: https://en.wikipedia.org/wiki/Symmetric-key_algorithm
[primitive root wiki]: https://en.wikipedia.org/wiki/Primitive_root_modulo_n
[discrete logarithm wiki]: https://en.wikipedia.org/wiki/Discrete_logarithm
[diffie-hellman 1976]: https://ee.stanford.edu/~hellman/publications/24.pdf
[willclarktech privacy-implementations]: https://github.com/willclarktech/privacy-implementations
[willclarktech implementation]: https://github.com/willclarktech/privacy-implementations/tree/a7797d7/src/cryptosystem/diffie-hellman
