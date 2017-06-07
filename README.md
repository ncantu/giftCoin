# giftCoin
A smart contract gift Coin auctions on a private blockchain

Install the development environment :

Install VirtualBox
Add this image https://drive.google.com/open?id=0B8rZeDVmrvHGcEtMLTVIT0RWTzA from https://github.com/asseth/assethbox

mkdir /tmp/geth /tmp/geth/data /tmp/geth/ipc /tmp/mist /tmp/geth
geth --ipcpath /tmp/geth/ipc/geth.ipc --datadir /tmp/geth/data --dev console
> personal.newAccount();
> miner.start();

usr/local/bin/mist --rpc /tmp/geth/ipc/geth.ipc 
