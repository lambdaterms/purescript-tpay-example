# purescrit-tpay-example

Example application using Tpay integration. Runs a hyper web-server with page to create new transaction
and to review received confirmations.

 - `/` serves template in `Views/Index`
 - `/summary` serves template in `Views/Summary`
 - `/buy` serves template in `Views/Buy`
 - `/notif` exposes notification endpoint to be used by Tpay

To run the example You will need to expose server on the internet using f.e.
[serveo](https://serveo.net/). Then You will have to set the notifications link
in Tpay administrative panel to `your.serveo.url/notif`.
Create new transactions via buy and check confirmations in summary.
