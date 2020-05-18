---
title: "Private set intersection with the Paillier cryptosystem"
description: "In this post we’ll see how a private set intersection protocol can be built using the Paillier cryptosystem."
category: tech
tags: [paillier, cryptography, private set intersection]
---

In the [previous post][paillier blogpost] we looked at the Paillier cryptosystem, which is a partial homomorphic encryption scheme enabling the addition of two ciphertexts as well as the multiplication of a ciphertext by a plaintext. In this post we’ll see how a [private set intersection][psi wiki] protocol can be built using the Paillier cryptosystem.

## Private set intersection

Private set intersection (PSI) is where two parties each have a set and one or both parties discover(s) the intersection between them without revealing the other elements in their respective sets. A salient example would be for a COVID-19 contact tracing app. Suppose a public health authority holds—in a centralised database—a list of geocoordinates with timestamps corresponding to the location history of individuals known to be infected. Members of the public with smartphones may hold a set of their own geocoordinates with timestamps. How can those people find out if they have been in close proximity to an infected person?

A naïve approach would involve those people sending their complete location histories to the public health authority for comparison with the data in the centralised database. This raises obvious concerns about privacy. Instead, PSI allows those people to find out whether their location history intersects with the public health authority’s set of known infected locations _without revealing their location history to the public health authority_.

Does it sound too good to be true? Well, any PSI protocol is going to involve some computational overhead, so it’s not entirely for free. However, in many cases the trade-off may well be worthwhile.

## The protocol

Alice (the client) and Bob (the server) each have a set of elements from some domain and Alice wants to discover the intersection of her set with Bob’s set, but Alice doesn't want to reveal her set to Bob and Bob doesn’t want to reveal what’s in his set to Alice, besides the intersection. Here’s how the protocol works:

1. Alice generates a public-private key pair according to the Paillier cryptosystem.
1. For each element in the domain, Alice encrypts a 1 or a 0 indicating whether that element is present in her set.
1. Alice sends the encrypted values and her public key to Bob.
1. Bob multiplies each encrypted value by a plaintext 1 or 0 depending on whether that element is present in his set, according to the Paillier multiplication process.
1. Bob sends the encrypted multiplication results back to Alice.
1. Alice decrypts the encrypted results to reveal the results of multiplying her 1s and 0s by Bob’s 1s and 0s in plaintext. The intersection consists of the elements in the domain where the multiplication result is 1.

(Multiplying these 1s and 0s is essentially the same as treating them as boolean values and performing an `AND` operation on them.)

Note that it is very important Bob uses a Paillier implementation which avoids the gotchas listed in the previous post to do with multiplying by 0 and 1. Otherwise, whenever Bob multiplies one of Alice’s encrypted values by 0, Alice or an eavesdropper will be able to detect that and infer that the corresponding elements are _not_ in Bob’s set, that all of the other elements _are_ in Bob’s set, and thus the protocol is not private at all. A similar problem arises if multiplication by 1 is not performed securely.

## Extending the protocol

The protocol can be extended to share even less information with the client than the intersection.

### Intersection size

Suppose it is not important to Alice what the actual intersection is, and Bob does not want to reveal any elements of his set at all. To go back to the example of COVID-19 and infected locations, suppose Alice does not need to know which specific infected locations she was in, just how many times she has been in some infected location or other. Alice can still find out the size of the information using a slightly modified protocol. Instead of Bob sending all the multiplied values back to Alice, he instead sums them together using Paillier addition of ciphertexts, and sends the sum back to Alice. When Alice decrypts Bob’s response she will discover the size (or _cardinality_) of the intersection, without learning that any specific elements are present in Bob’s set.

### Intersection empty/non-empty

If it isn’t important to Alice which specific elements make up the intersection, it might not even be important to her how large the intersection is. To pick up the COVID-19 example again, maybe Alice will quarantine herself if she has been in one or more infected location, but carry on as normal if the intersection is empty. In this case Bob can calculate the encrypted sum as before, but before sending it back to Alice he generates a random plaintext integer (larger than 0!) and multiplies the sum by this number (using the Paillier multiplication process). Then when Alice decrypts the result it will either be 0, indicating an empty intersection, or an integer larger than zero. In the latter case Alice will know that the intersection is not empty, but as long as the random number was generated using enough entropy she will not be able to extract the size of the intersection, let alone any specific members.

## Code

As with the previous post, I have implemented PSI with Paillier in [my learning repository][willclarktech privacy-implementations]. Instructions for downloading and setting up the repository are in [the previous post][paillier blogpost].

**WARNING: This library is not recommended for production use. It was written for learning purposes only.**

Here is how to use the PSI with Paillier module:

```js
const { Client, Server } = require("./build/private-set-intersection/paillier");

const domainSize = 50;
const clientSet = new Set([0, 5, 10, 15, 20, 25, 30, 35, 40, 45]);
const serverSet = new Set([0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48]);

const client = new Client(domainSize, clientSet); // Slow! (Generates Paillier key pair)
const server = new Server(serverSet);

const values = client.getEncryptedValues();

const intersectionResponse = server.revealIntersection(
  client.publicKey,
  values
);
const intersection = client.handlIntersectionResponse(intersectionResponse); // [0, 20, 40]

const intersectionSizeResponse = server.revealIntersectionSize(
  client.publicKey,
  values
);
const intersectionSize = client.handleIntersectionSizeResponse(
  intersectionSizeResponse
); // 3

const intersectionNonEmptyResponse = server.revealIntersectionNonEmpty(
  client.publicKey,
  values
);
const intersectionNonEmpty = client.handleIntersectionNonEmptyResponse(
  intersectionNonEmptyResponse
); // true
```

## Limitations

This PSI protocol is really good against eavesdroppers because they only ever see encrypted values indicating the presence or absence of each element in the domain, and can infer no information about either set. However, it comes with a number of limitations, including:

1. It assumes that the server is honest: a dishonest server could just lie about their set to the client and the client would be unable to do anything about it.
1. It assumes that the client is honest: a dishonest client could just pretend their set includes every element in the domain and derive the server’s complete set from the server’s response. If using the alternative protocols, the client can derive the size of the server’s set/whether the server’s set is empty, which may be less of a problem.
1. Even using one of the more restricted protocols is insecure for small domains: an attacker could send a request to the server for each element in the domain with a set containing just that element. Based on the boolean response, the attacker can derive the server’s full set.
1. It is impractical for large domains because every element in the domain must be encrypted and multiplied. Also one encrypted value (i.e. a large number) for each element of the domain must be sent from client to server and back again. This quickly adds up to a lot of computation and a lot of bandwidth!

## Summary

In this post we’ve seen how to develop the Paillier cryptosystem into a PSI protocol which has some limitations. Next time, we’ll look at the Diffie-Hellman key exchange protocol, which can form the basis of a different PSI protocol which gets around some of these limitations.

## Links

- [covid-alert][covid-alert], a demo application from [OpenMined][openmined] for the COVID-19 use-case using PSI with Paillier
- [Node.js implementation][willclarktech implementation] from my privacy learning repository

[paillier blogpost]: /tech/2020/05/15/paillier-cryptosystem.html
[psi wiki]: https://en.wikipedia.org/wiki/Private_set_intersection
[willclarktech privacy-implementations]: https://github.com/willclarktech/privacy-implementations
[covid-alert]: https://github.com/OpenMined/covid-alert
[openmined]: https://openmined.org/
[willclarktech implementation]: https://github.com/willclarktech/privacy-implementations/tree/ac7133a/src/private-set-intersection/paillier
