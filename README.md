![alt text](https://www.datocms-assets.com/2885/1506458488-blog-vault-list.svg "Vault")

# Hashicorp vault-posgres-ldap demo

**Note:** This is a playground for using Vault with postgres and LDAP, all required keys for unseal and play around with vault vault are provided:

    - Unseal KEY1 = Rz7nccNNLEE0e0W+yQPB6KrATAMmNmuUGYGHaS6aMhBe
    - Unseal KEY2 = OIHfdY93utohv4EyZaMS8FDTyjTzmay4UrSNghF5LOTl
    - Unseal KEY3 = iYTOc19DXO/lJhoui4Xf+U9Eic1IkOkLL9cz4I246pPG
    - Unseal KEY4 = 30vVo6EqJ0bXv6d4DGLS3ql127FqQc37Y7l8hFI87v6v
    - Unseal KEY5 = bwPEaO85ixhLnTnAtJ4lPkbo+96U/GzzLOUxDXee6b4Z
    - ROOT_TOKEN  = 5d9e40a3-eb45-7e9b-53ff-e32a70dfabe0

Vault initialized with 5 keys and a key threshold of 3. When the Vault is re-sealed, restarted, or stopped, you must provide at least 3 of these keys to unseal it again.

For the different configurations please have a look at the *vault_notes.txt* file where you can find some commands that were used for vault's configuration.

## Spining up the demo

### Prerequisites
1. [Docker installed] (https://docs.docker.com/install/)
2. [Vault installed] (https://www.vaultproject.io/intro/getting-started/install.html)

### Steps
1. Start the environment: ```docker-compose up -d```
2. Set the Vault server host: ```export VAULT_ADDR='http://127.0.0.1:8200'```
3. Unseal Vault: repeat 3 times ```vault operator unseal <KEY>```
4. Login to Vault: ```vault login <ROOT_TOKEN>```
5. Get a postgres credential: ```vault read database/creds/readonly```

### Validate postgres user was created
1. connect to postgres container ```docker exec -it postgres /bin/bash```
2. inside the container, connect to db ```psql -h localhost -U postgres myapp```
3. inside postrgres db, check the users: ```myapp> \du```
