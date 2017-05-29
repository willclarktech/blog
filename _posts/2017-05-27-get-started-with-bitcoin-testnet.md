---
title: "Get started with the Bitcoin Testnet"
description: "Try out JS Bitcoin development for free with the Testnet"
category: tech
tags: [bitcoin, cryptocurrency, testing, js]
---

I recently incorporated logging data to the Bitcoin blockchain into my [blockchain-logger](https://github.com/willclarktech/blockchain-logger) project, using the [Testnet](https://en.bitcoin.it/wiki/Testnet) to try things out without risking real Bitcoin. This is a tutorial-style distillation of what I did, covering:

1. Picking a JS Bitcoin library.
1. Creating a private/public key pair.
1. Obtaining Bitcoin on the Testnet for free.
1. Reading data from the Testnet blockchain via a third party API.
1. Building valid transactions, including `OP_RETURN` transactions.
1. Pushing those transactions to a third party API for transmission to the Testnet network.

## Setup

I’ll be using Node with modern JavaScript in my examples, so you’ll need to have installed a recent version of Node (ideally via a version manager such as [n](https://github.com/tj/n)). I’m on v7.8.0.

I’m assuming you’re in a directory where you can play around and install node modules etc.

## Picking a JS Bitcoin library

I opted for [bitcoinjs-lib](https://github.com/bitcoinjs/bitcoinjs-lib) for the following reasons:

1. It’s still active (latest commit 2 days ago at time of writing).
1. It has a large number of contributors and releases.
1. The main contributor, [dcousens](https://github.com/dcousens), has also contributed a lot to [Bitcoin Core](https://github.com/bitcoin/bitcoin/commits?author=dcousens).
1. It’s pretty comprehensive in terms of functionality, including paying to scripts besides just addresses.
1. It’s geared towards Bitcoin-related functions, rather than running a full node.
1. It has a folder full of clear examples.
1. It’s used by some high-profile companies/organisations including [Blockchain.info](https://blockchain.info/), which I took to be a good sign.
1. Flow types are available via [flow-typed](https://github.com/flowtype/flow-typed/tree/master/definitions/npm/bitcoinjs-lib_v2.x.x) (although they’re out of date and some are incompatible with the latest release).

[bitcore-lib](https://www.npmjs.com/package/bitcore-lib) looked like another, very similar option, but (a) didn’t seem quite as active (latest commit 2 months ago), and (b) bitcoinjs-lib already looked good enough to me.

The easiest way to install the latest release is with yarn or npm:

```sh
yarn add bitcoinjs-lib
# or
npm install bitcoinjs-lib
```

## Creating a private/public key pair

In order to do anything with Bitcoin, you need a private/public key pair. The public key can be used by other people to send you Bitcoin, and the private key can be used by you to send Bitcoin to someone else by verifying that it’s really you who created the transaction.

We can do this like so:

```js
const bitcoin = require('bitcoinjs-lib')
const { testnet } = bitcoin.networks
const myKeyPair = bitcoin.ECPair.makeRandom({ network: testnet })
```

"EC" in "ECPair" presumably stands for "elliptic curve" as in [elliptic curve cryptography](https://en.wikipedia.org/wiki/Elliptic_curve_cryptography) aka the maths underlying the security of Bitcoin.

Great! You’ve got a key pair. But where are the actual keys? Logging `myKeyPair` probably won’t leave you much the wiser.

Well, `myKeyPair` has methods which will use these keys to eg sign transactions, but you probably don’t need to use the raw keys themselves. Instead, try this:

```js
const myWIF = myKeyPair.toWIF() // eg 'cP4B7GnH9vqGvQr72BVgXRLR1kUzCpHQJeSYCGNHjAGfw2EcDFEt'
const myAddress = myKeyPair.getAddress() // eg 'movqJvueABnqpXUXVwQZbgU6fZANd2YsTD'
```

`myWIF` here is your private key in Wallet Import Format (WIF), which also includes information about whether it’s the main network or Testnet, and a checksum to help guard against typos, in base58 encoding. (base58 consists of numbers and upper- and lowercase letters, except O, 0, l and I which can easily be mistaken for each other.) You can use `myWIF` to import your wallet into many GUI wallet providers such as Blockchain.info. Anyone else can too, so if you do this later with real Bitcoin keep `myWIF` secret.

`myAddress` is similarly encoded, except this you can give to people who want to send you Bitcoin.

## Getting free Testnet coins

Now you have an address, it’s time to get some free Testnet Bitcoins. Bitcoins on the Testnet are deliberately kept valueless by the threat of resetting the network if people start trading them for real money, and there are plenty of places giving out coins for free so you can test out your Bitcoin application without risking real money.

The best faucet I found was [https://testnet.manu.backend.hamburg/faucet](https://testnet.manu.backend.hamburg/faucet) which will give you 1–2 Bitcoin in a single payout—more than enough to play with. Now that you have your address, just enter it into the form there to get your coins. After a few minutes you should see your transaction get some confirmations, effectively meaning the network now recognizes you own those Bitcoin.

Congratulations, you’re now the proud owner of some worthless cryptocurrency! By the way, it’s considered polite to return your Testnet coins to a faucet when you’re done with them so other people can use them.

## Reading data from the Testnet blockchain

The Testnet blockchain is entirely public, just like the main Bitcoin blockchain. So you can pick your favourite block explorer or even run your own node and explore it yourself. Here we’ll use [smartbit](https://www.smartbit.com.au/) because they have a solid API, a really nice documentation site, and you don’t need an API key.

The documentation site is [here](https://testnet.smartbit.com.au/api). Expand the ADDRESS section, click on PARAMETERS, and enter your address in the Address ID field. Click GET and you should see various information about your address, in particular about the Bitcoin you just got sent from the faucet. (If nothing shows up you might need to wait a few minutes for the transaction to be detected.)

Now let’s do that in Node. I’ll use [axios](https://github.com/mzabriskie/axios) for some friendly Promises.

```sh
yarn add axios
# or
npm install axios
```

Here’s that same smartbit query using their API:

```js
const axios = require('axios')
const urlForMyAddress = `https://testnet-api.smartbit.com.au/v1/blockchain/address/${myAddress}`
axios
  .get(urlForMyAddress)
  .then(response => console.log(response.data))
```

Or if we’re only interested in the unspent transactions for our address:

```js
const urlForMyUnspentTransactions = `${urlForMyAddress}/unspent`
axios
  .get(urlForMyUnspentTransactions)
  .then(response => console.log(response.data))
```

As a reusable function:

```js
const getUnspentTransactionsForAddress = address => {
  const url = `https://testnet-api.smartbit.com.au/v1/blockchain/address/${address}/unspent`
  return axios
    .get(url)
    .then(response => response.data.unspent)
}
```

## Building a valid transaction

OK, let’s spend some coins. Here’s what we need to do:

1. Decide which address we want to send coins to.
1. Decide how much to send to that address.
1. Calculate an appropriate fee for the miner who will include the transaction in a block.
1. Find a transaction with an unspent output to our address to use as the input to our transaction.
1. Sign the transaction input.
1. Add an output to our transaction so the receiver gets the coins we want to give them.
1. Add an output back to our own address for change.

Create a second key pair to send coins to, if you don’t have somewhere to send them already, and specify an amount to send them in [satoshis](https://bitcoin.stackexchange.com/questions/114/what-is-a-satoshi):

```js
const receiver = bitcoin.ECPair.makeRandom({ network: testnet })
const amountToSend = 5000000 // 0.05 BTC
```

The fee is important because if you set it too low then your transaction won’t be attractive to miners, and might take a long time to appear in the blockchain or it might even never get accepted. This is not such a problem on the Testnet where there isn’t so much traffic, but is a big issue for the Bitcoin main network. We can practise setting a sensible fee using [21.co’s](https://21.co/) recommended fees.

```js
const getRecommendedFee = () => {
  const url = 'https://bitcoinfees.21.co/api/v1/fees/recommended'
  const medianTransactionSize = 226 // bytes
  return axios
    .get(url)
    .then(response => response.fastestFee * medianTransactionSize)
}
```

You can also choose `halfHourFee` or `hourFee`, but (a) this is the testnet so we don’t need to be precious with satoshis, and (b) these are the recommended fees for the main network anyway, so entirely unrelated to the Testnet. We’re just including them here for practice.

The result from 21.co tells you the fee recommended *per byte* of transaction data. I’m multiplying by the median transaction size (again for the main net, not the Testnet) for convenience, but if you were creating large transactions you’d probably want to work out how large your actual transaction is so that the recommended fees perform as expected.

Now we have everything we need to start building the transaction.

```js
const buildTransaction = (keyPair, receiverAddress, amount) =>
  Promise.all([
    getUnspentTransactionsForAddress(keyPair.getAddress()),
    getRecommendedFee(),
  ])
    .then(([unspentTransactions, recommendedFee]) => {
      const unspent = unspentTransactions[0]
      const totalCost = amount + recommendedFee
      const change = unspent.value_int - totalCost

      const tx = new bitcoin.TransactionBuilder(testnet)
      tx.addInput(unspent.txid, unspent.n)
      tx.sign(0, keyPair)
      tx.addOutput(receiverAddress, amount)
      tx.addOutput(keyPair.getAddress(), change)

      return tx.build()
    })
```

Here’s what happens in our function. We get a list of transactions with unspent outputs for our address. We pick the first transaction (eg the one from the faucet). We also get the recommended fee via 21.co’s API.

Then we start building a transaction. We add the unspent output as an input, using its transaction id and `unspent.n` which specifies which output in that transaction we’re using (remember that transactions can have multiple outputs). Then we sign that input using our key pair (`0` specifies which input we’re signing, ie the first one).

Then we add outputs sending the desired amount to the receiver address, and the change back to our own address. We calculate how much change there is by subtracting the amount we’re sending and the fee we want to pay from the unspent amount.

**IMPORTANT**: We need to send the change back to our address because any amounts not specified in outputs get used up as mining fees. Forgetting this step can be very expensive!

Finally we build the transaction and return it.

## Building an `OP_RETURN` transaction

Sending money from one wallet to another is only one of the functions made possible by the blockchain. Another is storing data in an immutable database. This is possible by way of an `OP_RETURN`, which produces an *unspendable* output, along with a message of up to 80 bytes.

We need a slightly different function:

```js
const buildOpReturnTransaction = (keyPair, message) =>
  Promise.all([
    getUnspentTransactionsForAddress(keyPair.getAddress()),
    getRecommendedFee(),
  ])
    .then(([unspentTransactions, recommendedFee]) => {
      const unspent = unspentTransactions[0]
      const change = unspent.value_int - recommendedFee
      const dataToStore = Buffer.from(message)
      const opReturnScript = bitcoin.script.nullData.output.encode(dataToStore)

      const tx = new bitcoin.TransactionBuilder(testnet)
      tx.addInput(unspent.txid, unspent.n)
      tx.sign(0, keyPair)
      tx.addOutput(opReturnScript, 0)
      tx.addOutput(keyPair.getAddress(), change)

      return tx.build()
    })  
```

Like before we get our unspent transaction and recommended fee. We convert our message to a buffer in case it isn’t one already, and create an `OP_RETURN` script which we’ll use as one of the outputs, sending 0 satoshis. We send all of the unspent amount (minus the fee) back to our own address. As before we build the transaction and return it.

**IMPORTANT**: If you send any coins to an `OP_RETURN` script they’re gone forever. Make a mistake with fees and a nice miner might (but probably won’t!) decide to send you your coins back. Make a mistake with `OP_RETURN` and nobody can get them back for you even if they wanted to.

## Pushing a transaction to the network

OK, we can build transactions. But right now we’re the only ones who know about them. We’ve got to get them into the network somehow so the miners can include them in a block.

```js
const pushTransaction = transaction => {
  const url = 'https://testnet-api.smartbit.com.au/v1/blockchain/pushtx'
  const params = { hex: transaction.toHex() }
  return axios.post(url, params)
}
```

Easy! You can also post the request to `/decodetx` rather than `/pushtx` to double check that the transaction looks the way you’re expecting before broadcasting it.

Here’s an example using our functions to create an `OP_RETURN` transaction:

```js
const importantMessage = 'For good luck, I like my rhymes atrocious\nSupercalafragilisticexpialidocious'
buildTransaction(myKeyPair, importantMessage)
  .then(pushTransaction)
  .then(response => console.log(response.data))
```

Go check it out in a Testnet blockchain explorer in a browser—just search for your address and you should see an `OP_RETURN` output with your message on the public blockchain (once the transaction has been included in a block).

You can also get these messages out of the blockchain later using smartbit’s `/address/${myAddress}/op_returns` endpoint.

## Conclusion

It can seem difficult to get started developing with Bitcoin because (a) a lot of Bitcoin code is written in low-level languages like C++, (b) it takes a fair amount of setup and system resources to run a full node, and (c) Bitcoin is valuable so mistakes can be very expensive. Hopefully this post has shown that you can get started really easily using JavaScript, third-party APIs, and the Testnet.

### P.S.

Sorry for the broken syntax highlighting. If you feel like making a noise [here](https://github.com/jekyll/jekyll/pull/5230) it might get fixed sooner.
