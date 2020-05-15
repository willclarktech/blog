---
title: "Paillier Cryptosystem"
description: "Introduction to the Paillier cryptosystem"
category: tech
tags: [paillier, cryptography, homomorphic encryption]
math: true
---

This post introduces the Paillier cryptosystem, which is a partial homomorphic encryption scheme. In a subsequent post we’ll see how this can be used as the basis for a private set intersection protocol.

## Homomorphic encryption

[Homomorphic encryption][homomorphic encryption wiki] is a form of encryption which allows you to perform mathematical or logical operations on the encrypted data. For example, suppose we have two numbers $$m_1$$ and $$m_2$$ and we encrypt those numbers using some [public key encryption scheme][public key cryptography wiki] with a public key $$pub$$ and a private key $$priv$$. We get two ciphertexts $$c_1 = E_{pub}(m_1)$$ and $$c_2 = E_{pub}(m_2)$$. Normally, encryption aims to make all encrypted numbers indistinguishable from random numbers for anyone who does not have the private key required for decryption.

However with homomorphic encryption, some relationships are preserved. For example, if we have a homomorphic encryption scheme which enables addition, there will be a function $$add$$ which anyone can perform on $$c_1$$ and $$c_2$$ such that the result, $$add_{pub}(c_1, c_2)$$, will decrypt to the sum of $$m_1$$ and $$m_2$$:

$$
D_{priv}(add_{pub}(E_{pub}(m_1), E_{pub}(m_2))) = m_1 + m_2
$$

Note that the $$add$$ function will not necessarily be _literal_ addition, just whichever function plays the role described above, according to the relevant homomorphic encryption scheme.

There have been partial homomorphic encryption schemes for quite a while, where a limited number of operations can be performed on encrypted data, for example only addition or only multiplication. Fully homomorphic encryption schemes have been developed over the last decade or so, which support _arbitrary computations_ on encrypted data.

The [Paillier cryptosystem][paillier cryptosystem wiki], invented by Pascal Paillier in 1999, is a partial homomorphic encryption scheme which allows two types of computation:

- addition of two ciphertexts
- multiplication of a ciphertext by a plaintext number

## Public key encryption scheme

The basic public key encryption scheme has three stages:

1. generate a public-private key pair
1. encrypt a number
1. decrypt a number

### Helper functions

1. $$\mathrm{gcd}(x, y)$$ outputs the greatest common divisor of $$x$$ and $$y$$.
1. $$\mathrm{lcm}(x, y)$$ outputs the least common multiple of $$x$$ and $$y$$.

### Key generation

Key generation works as follows:

1. Pick two large prime numbers $$p$$ and $$q$$, randomly and independently. Confirm that $$\mathrm{gcd}(pq, (p-1)(q-1))$$ is $$1$$. If not, start again.
1. Compute $$n = pq$$.
1. Define function $$L(x) = \frac{x - 1}{n}$$.
1. Compute $$\lambda$$ as $$\mathrm{lcm}(p-1, q-1)$$.
1. Pick a random integer $$g$$ in the set $$\mathbb{Z}^*_{n^2}$$ (integers between 1 and $$n^2$$).
1. Calculate the [modular multiplicative inverse][modular multiplicative inverse wiki] $$\mu = (L(g^\lambda \mod n^2))^{-1} \mod n$$. If $$\mu$$ does not exist, start again from step 1.
1. The public key is $$(n, g)$$. Use this for encryption.
1. The private key is $$\lambda$$. Use this for decryption.

### Encryption

Encryption can work for any $$m$$ in the range $$0 \leq m < n$$:

1. Pick a random number $$r$$ in the range $$0 < r < n$$.
1. Compute ciphertext $$c = g^m \cdot r^n \mod n^2$$.

### Decryption

Decryption presupposes a ciphertext created by the above encryption process, so that $$c$$ is in the range $$0 < c < n^2$$:

1. Compute the plaintext $$m = L(c^\lambda \mod n^2) \cdot \mu \mod n$$.

(Reminder: we can always recalculate $$\mu$$ from $$\lambda$$ and the public key).

### Example

Here are some example values if you want to work through the algorithm:

#### Key generation

1. Pick $$p = 13$$ and $$q = 17$$. (They satisfy the condition.)
1. Compute $$n = 221$$.
1. Compute $$\lambda = 48$$.
1. Pick $$g = 4886$$.
1. Compute $$\mu = 159$$. (It exists.)

#### Encryption

1. Set $$m_1 = 123$$.
1. Pick $$r_1 = 666$$.
1. Compute $$c_1 = 25889 \mod 221^2$$.

#### Decryption

1. Compute $$m_{decrypted} = 123 \mod 221$$. (The same as $$m_1$$.)

(But beware these numbers are too small to offer any real security and my random values weren’t all that random.)

## Homomorphic properties

Let’s take a look at the homomorphic properties of this encryption scheme...

### Addition of two ciphertexts

When two ciphertexts are multiplied, the result decrypts to the sum of their plaintexts:

$$
D_{priv}(E_{pub}(m_1) \cdot E_{pub}(m_2) \mod n^2) = m_1 + m_2 \mod n
$$

### Multiplication of a ciphertext by a plaintext

When a ciphertext is raised to the power of a plaintext, the result decrypts to the product of the two plaintexts:

$$
D_{priv}(E_{pub}(m_1)^{m_2} \mod n^2) = m_1 \cdot m_2 \mod n
$$

### Gotchas

There are a couple of special cases which need to be handled carefully. The first is multiplying by $$0$$. Because any number to the power of $$0$$ is $$1$$, if we multiply a ciphertext by a plaintext $$0$$ using the method above, the result will always be $$1$$, and anyone who sees this "encrypted" value will know that it decrypts to $$0$$. Luckily we can use an alternative method for this case. Because multiplying any number by $$0$$ gives $$0$$, we can just skip the calculations and encrypt a $$0$$ directly using the standard public key encryption scheme. Because of the random number introduced in the encryption step, nobody without the private key will be able to know what the plaintext is.

The other case is multiplying by $$1$$. Because any number $$x$$ to the power of $$1$$ is $$x$$, if we multiply a ciphertext by a plaintext $$1$$ using the normal method, the output will be the same as the input. This is less severe than the case with $$0$$ where the encrypted value could be inferred, but still a problem because anybody who is watching the communication between whoever holds the private key and whoever is multiplying numbers will be able to work out that the number was multiplied by $$1$$. The solution is another workaround: instead of multiplying by $$1$$, we perform an equivalent operation: adding $$0$$! We just freshly encrypt a $$0$$ and perform the usual addition procedure to obtain a secure ciphertext.

### Example

Here are some example values continuing from the last example:

#### Homomorphic addition

1. Set $$m_2 = 37$$.
1. Pick $$r_2 = 999$$.
1. Compute $$c_2 = 30692 \mod 221^2 $$.
1. Compute $$c_{sum} = 25889 \cdot 30692 = 39800 \mod 221^2$$.
1. Compute $$m_{sum} = 160 = 123 + 37 = m_1 + m_2 \mod 221$$.

#### Homomorphic multiplication

1. Set $$m_3 = 25$$.
1. Compute $$c_{product} = 25889^{25} = 15723 \mod 221^2$$.
1. Compute $$m_{product} = 202 = 123 \cdot 25 = m_1 \cdot m_3 \mod 221$$.

#### Multiplication by 0

1. Set $$m_{multiply0} = 0$$.
1. Pick $$r_{multiply0} = 444$$.
1. Compute $$c_{multiply0} = 46663 \mod 221^2$$.
1. Compute $$m_{decrypted} = 0 = 123 \cdot 0 = m_1 \cdot 0 \mod 221$$.

#### Multiplication by 1

1. Set $$m_{encrypt0} = 0$$.
1. Pick $$r_{encrypt0} = 555$$.
1. Compute $$c_{encrypt0} = 653 \mod 221^2$$.
1. Compute $$c_{multiply1} = 25889 \cdot 653 = 6531 \mod 221^2$$.
1. Compute $$m_{multiply1} = 123 = 123 \cdot 1 = m_1 \cdot 1 \mod 221$$.

## Code

I have a learning repository for privacy-related algorithms [here][willclarktech privacy-implementations]. You can have a look there to see how I implemented these functions, but here’s how you can use the library.

**WARNING: This library is not recommended for production use. It was written for learning purposes only.**

Assuming you have Git and Node.js with npm installed:

```shell
git clone https://github.com/willclarktech/privacy-implementations.git
cd privacy-implementations
npm install
npm run build
```

Now in a JavaScript file or Node.js REPL:

```js
const paillier = require("./build/cryptosystem/paillier");

const keys = paillier.generateKeysSync(); // Slow!

const plaintext1 = 1234567890n;
const plaintext2 = 55555555555n;

const ciphertext1 = paillier.encrypt(keys.pub)(plaintext1);
const ciphertext2 = paillier.encrypt(keys.pub)(plaintext2);

const ciphertextSum = paillier.add(keys.pub)(ciphertext1, ciphertext2);
const plaintextSum = paillier.decrypt(keys)(ciphertextSum); // 56790123445n = plaintext1 + plaintext2

const ciphertextProduct = paillier.multiply(keys.pub)(ciphertext1, plaintext2);
const plaintextProduct = paillier.decrypt(keys)(ciphertextProduct); // 68587104999314128950n = plaintext1 * plaintext2

const ciphertextMultiply0 = paillier.multiply(keys.pub)(ciphertext1, 0n); // != 1n
const ciphertextMultiply1 = paillier.multiply(keys.pub)(ciphertext1, 1n); // != ciphertext1
```

## Summary

In this post we’ve covered the Paillier cryptosystem, looking at how encryption, decryption, addition, and multiplication work. Next time we’ll take a look at how this can be used as a basis for a private set intersection protocol.

## Links

- [Paillier’s original paper][paillier 1999]
- [Node.js implementation][willclarktech implementation] from my privacy learning repository
- [Pure JavaScript implementation][openmined implementation] from [OpenMined][openmined]
- [A Python implementation][data61 implementation]

[homomorphic encryption wiki]: https://en.wikipedia.org/wiki/Homomorphic_encryption
[public key cryptography wiki]: https://en.wikipedia.org/wiki/Public-key_cryptography
[paillier cryptosystem wiki]: https://en.wikipedia.org/wiki/Paillier_cryptosystem
[modular multiplicative inverse wiki]: https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
[willclarktech privacy-implementations]: https://github.com/willclarktech/privacy-implementations
[paillier 1999]: https://www.cs.tau.ac.il/~fiat/crypt07/papers/Pai99pai.pdf
[willclarktech implementation]: https://github.com/willclarktech/privacy-implementations/tree/ac7133a/src/cryptosystem/paillier
[openmined implementation]: https://github.com/OpenMined/paillier-pure
[openmined]: https://openmined.org/
[data61 implementation]: https://github.com/data61/python-paillier
