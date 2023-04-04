#Setting up constants
FURY_HOME=$HOME/.fury
FURY_SRC=$FURY_HOME/src/fury
COSMOVISOR_SRC=$FURY_HOME/src/cosmovisor

FURY_VERSION="v1.0.1"
COSMOVISOR_VERSION="cosmovisor-v1.0.1"

mkdir -p $FURY_HOME
mkdir -p $FURY_HOME/src
mkdir -p $FURY_HOME/bin
mkdir -p $FURY_HOME/logs
mkdir -p $FURY_HOME/cosmovisor/genesis/bin
mkdir -p $FURY_HOME/cosmovisor/upgrades/

echo "-----------installing dependencies---------------"
sudo dnf -y update
sudo dnf -y copr enable ngompa/musl-libc
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf -y install subscription-manager
sudo subscription-manager config --rhsm.manage_repos=1
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
sudo dnf makecache --refresh
sudo dnf -y --skip-broken install curl nano ca-certificates tar git jq gcc-c++ gcc-toolset-9 openssl-devel musl-devel musl-gcc gmp-devel perl python3 moreutils wget nodejs make hostname procps-ng pass libsecret pinentry crudini cmake

gcc_source="/opt/rh/gcc-toolset-9/enable"
if test -f $gcc_source; then
   source gcc_source
fi

set -eu

echo "--------------installing golang---------------------------"
curl https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz --output $HOME/go.tar.gz
tar -C $HOME -xzf $HOME/go.tar.gz
rm $HOME/go.tar.gz
export PATH=$PATH:$HOME/go/bin
export GOPATH=$HOME/go
echo "export GOPATH=$HOME/go" >> ~/.bashrc
go version

echo "----------------------installing fury---------------"
git clone -b furyhub-1 https://github.com/fanfury-sports/fanfury.git $FURY_SRC
cd $FURY_SRC
make build
mv fury $FURY_HOME/cosmovisor/genesis/bin/fury

echo "-------------------installing cosmovisor-----------------------"
git clone -b $COSMOVISOR_VERSION https://github.com/onomyprotocol/onomy-sdk $COSMOVISOR_SRC
cd $COSMOVISOR_SRC
make cosmovisor
cp cosmovisor/cosmovisor $FURY_HOME/bin/cosmovisor

echo "-------------------adding binaries to path-----------------------"
chmod +x $FURY_HOME/bin/*
export PATH=$PATH:$FURY_HOME/bin
chmod +x $FURY_HOME/cosmovisor/genesis/bin/*
export PATH=$PATH:$FURY_HOME/cosmovisor/genesis/bin

echo "export PATH=$PATH" >> ~/.bashrc

# set the cosmovisor environments
echo "export DAEMON_HOME=$FURY_HOME/" >> ~/.bashrc
echo "export DAEMON_NAME=fury" >> ~/.bashrc
echo "export DAEMON_RESTART_AFTER_UPGRADE=true" >> ~/.bashrc


# Note: Download the keys files
git clone https://github.com/gridironzone/gridtestnet-1
cd gridtestnet-1/testnet-1
mv keys ~/
cd 
rm -rf ~/.fury

PASSWORD="F@nfuryG#n3sis@fury"
GAS_PRICES="0.000025utfury"
CHAIN_ID="gridiron_4200-3"
NODE="(fury tendermint show-node-id)"

fury init gridiron_4200-3 --chain-id $CHAIN_ID --staking-bond-denom utfury


# Note: Download the genesis file
curl -o ~/.fury/config/genesis.json https://raw.githubusercontent.com/fanfury-sports/download-1/main/testnet-1/genesis.json

# Note: Add an account
yes $PASSWORD | fury keys import node5 ~/keys/node5.key


# Set staking token (both bond_denom and mint_denom)
STAKING_TOKEN="utfury"
FROM="\"bond_denom\": \"stake\""
TO="\"bond_denom\": \"$STAKING_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json
FROM="\"mint_denom\": \"stake\""
TO="\"mint_denom\": \"$STAKING_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json

# Set fury token (both for gov min deposit and crisis constant fury)
FEE_TOKEN="utfury"
FROM="\"stake\""
TO="\"$FEE_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json

# Set reserved bond tokens
RESERVED_BOND_TOKENS="" # example: " \"abc\", \"def\", \"ghi\" "
FROM="\"reserved_bond_tokens\": \[\]"
TO="\"reserved_bond_tokens\": \[$RESERVED_BOND_TOKENS\]"
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json

# Set min-gas-prices (using fury token)
FROM="minimum-gas-prices = \"\""
TO="minimum-gas-prices = \"0.000002$FEE_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/app.toml

MAX_VOTING_PERIOD="90s" # example: "172800s"
FROM="\"voting_period\": \"172800s\""
TO="\"voting_period\": \"$MAX_VOTING_PERIOD\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json

yes $PASSWORD | fury gentx node5 1000000utfury --chain-id $CHAIN_ID
fury collect-gentxs
fury validate-genesis

# Enable REST API
FROM="enable = false"
TO="enable = true"
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/app.toml

# Enable Swagger docs
FROM="swagger = false"
TO="swagger = true"
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/app.toml

# Broadcast node RPC endpoint
FROM="laddr = \"tcp:\/\/127.0.0.1:26657\""
TO="laddr = \"tcp:\/\/0.0.0.0:26657\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/config.toml

# Set timeouts to 1s for shorter block times
sed -i -e "s/timeout_commit = "5s"/timeout_commit = "1s"/g" "$HOME"/.fury/config/config.toml
sed -i -e "s/timeout_propose = "3s"/timeout_propose = "1s"/g" "$HOME"/.fury/config/config.toml


echo "The Gridiron Chain can now be started - Congratulation on being part of the Genesis!!"

