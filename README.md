# Running Tests Step by Step
#### If you want to run tests first of all make sure you have installed all required node moules:
> yarn install

##### Than you should run ganache-cli which will generate 10 account with private keys for you. 
##### We use local public/private keys (keys.json).
> ganache-cli -e 10000 --acount_keys_path test/keys.json

##### Then you should just run tests with truffle or hardhat.
> yarn test --network test

