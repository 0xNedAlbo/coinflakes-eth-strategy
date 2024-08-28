-include .env

# deps
update:; forge update
build  :; forge build
size  :; forge build --sizes

# storage inspection
inspect :; forge inspect ${contract} storage-layout --pretty

# specify which fork to use. set this in our .env
# if we want to test multiple forks in one go, remove this as an argument below
FORK_URL := ${ETH_RPC_URL} # BASE_RPC_URL, ETH_RPC_URL, ARBITRUM_RPC_URL

# if we want to run only matching tests, set that here
test := test_

# local tests without fork
test  :; forge test -vv 
trace  :; forge test -vvv 
gas  :; forge test 
test-contract  :; forge test -vv --match-contract $(contract) --fork-url ${FORK_URL} --evm-version cancun
test-contract-gas  :; forge test --gas-report --match-contract ${contract} --fork-url ${FORK_URL} --evm-version cancun
trace-contract  :; forge test -vvv --match-contract $(contract) --fork-url ${FORK_URL} --evm-version cancun
test-test  :; forge test -vv --match-test $(test) --fork-url ${FORK_URL} --evm-version cancun
test-test-trace  :; forge test -vvv --match-test $(test) --fork-url ${FORK_URL} --evm-version cancun
trace-test  :; forge test -vvvvv --match-test $(test) --fork-url ${FORK_URL} --evm-version cancun
snapshot :; forge snapshot -vv --fork-url ${FORK_URL} --evm-version cancun
snapshot-diff :; forge snapshot --diff -vv --fork-url ${FORK_URL} --evm-version cancun
trace-setup  :; forge test -vvvv --fork-url ${FORK_URL} --evm-version cancun
trace-max  :; forge test -vvvvv --fork-url ${FORK_URL} --evm-version cancun
coverage :; forge coverage --fork-url ${FORK_URL} --evm-version cancun
coverage-report :; forge coverage --report lcov --fork-url ${FORK_URL} --evm-version cancun
coverage-debug :; forge coverage --report debug --fork-url ${FORK_URL} --evm-version cancun


clean  :; forge clean
