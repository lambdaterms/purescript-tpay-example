# purescrit-tpay-example

## Install

This example (like `purescript-tpay`) depends on [`decimal.js`][decimal.js] so you need to install it (possibly by just running `npm install`).

## Usage

### Configuration

To run this application you need your tpay id (your login id) and tpay code (on the bottom of the page in secure.tpay.com: Ustawienia → powiadomienia). You should also turn on "testing" payments there: Ustawienia → tryb testowy.

Probably the easiest way to test payment flow from local machine is to use `serveo.net`:

```shell
$ ssh -R 80:localhost:3000 serveo.net
```

Copy domain which is printed on the console to this command:

```shell
$ nodemon server.js -- --tpay-id $TPAY_ID --tpay-secret $TPAY_CODE --base-url $DOMAIN
```

Open a browser and test your payment workflow.

