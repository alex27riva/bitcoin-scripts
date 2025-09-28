# bitcoin-scripts

Repo for my Bitcoin scripts

<img src="images/bitcoin-scripts.webp" width="400"/>

## RPC connection

- Configure bitcoind to allow incoming RPC connections

```bash
sudo vim /mnt/hdd/bitcoin/bitcoin.conf
```

Modify these two lines

```ini
rpcallowip=192.168.1.0/24
main.rpcbind=0.0.0.0:8332
```

Configure RPC credential in `.env` file

- Allow RPC in UFW from local network

```bash
sudo ufw allow from 192.168.1.0/24 to any port 8332 proto tcp comment 'Allow Bitcoin RPC from local network' && sudo ufw reload
```
