---
title: "Neural networks as steganographic vehicles"
description: "How to hide information in functioning neural networks"
category: tech
tags: [machine learning, infosec]
---

Steganography is the art of hiding information. Whereas cryptography aims to prevent people understanding information once it has been found, the goal of steganography is to prevent the information from being discovered in the first place. Of course, for any practical covert communication you’re likely to want to combine the two, so that even if the message is discovered it cannot be understood. In this blog post we’ll see how neural networks can be used as a vehicle for covert communication.

## Background

In a digital context, the steganographer wants to hide a payload inside another file (or set of files) in such a way that those files appear normal so that the existence of a message is not detected. For example, some PNG images store 3 bytes of RGB data for each pixel in the image (1 byte per colour channel). But modifying the least significant bit (LSB) of each of these bytes will not have a perceptible impact on how the image looks to a human observer. This gives us one of the classic steganographic techniques: serializing the payload data as a string of bits, and setting each LSB in the image data to the corresponding bit from the payload. To recover the hidden message, you simply read off the LSBs of the image’s RGB data.

This technique takes advantage of a general property of such vehicle files, which is that they have more precision than they need: the image in question could just as well have been stored in a format which used one bit fewer per RGB value. The steganographer repurposes the unused precision to store additional information.

## Application to neural networks

This brings us to neural networks as potential vehicles for steganography. Serialized neural networks are often very large files, which means they can potentially hold a lot of covert information without arousing suspicion, assuming they can be modified without affecting performance. The question is: can we use the same LSB technique here, by modifying the values of the network parameters, ie the weights and biases?

It turns out this works. There’s a proof of concept in my machine learning/infosec repository [here][demo]. In this example `sender.py` trains a simple PyTorch network that can categorize MNIST digits with >95% accuracy, and then adjusts the parameters using the LSB technique to store a secret image file. Then `receiver.py` loads this model, compares the performance of the original network with the modified network, and also reconstructs the image from the data stored in the modified network. The performance on the MNIST test set appears to be unaffected. It would be interesting to see whether this result holds for deeper networks (eg some of the widely used pre-trained networks) or the modifications add up to performance degradation when many layers are involved.

The data storage in this demo could probably be made more efficient by setting two LSBs per parameter (or three, or ...). And for situations where the LSB really is needed for the original performance level, you always have the option of artificially increasing the precision. For example if the original model works with 32-bit float values, you could just translate the model to 64-bit floats and gain 32 bits of storage per parameter. Of course this would drastically increase the size of the model file, which might be a problem.

## Implications

One obvious use case for this would be exfiltration: a tech company employee could upload a neural network somewhere, making the network request look innocent, but actually the parameters encode some company secrets.

Another intriguing possibility is that publicly available pre-trained networks could be used to disseminate a relatively large amount of arbitrary data for subsequent retrieval to a large number of machine learning practitioners’ machines, who may be considered a valuable target group for certain kinds of attack. This probably has very few applications, but could perhaps be useful for an attacker who can’t make arbitrary network requests on the victim’s machine and can only deliver a small payload using other means.

[demo]: https://github.com/willclarktech/ml-attacks/tree/9ad2147a628159c45cb37bfcf6d9842e0b0ec1df/src/pytorch_steganography
