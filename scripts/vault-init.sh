#!/bin/bash
export VAULT_ADDR="http://127.0.0.1:8200/"

echo "Unsealing Vault ...."
for key in {1..3}
do
  vault operator unseal $(grep "KEY${key}" ../README.md | awk '{print $NF}')
done

sleep 2

echo "Vault login...."
vault login -no-print \
$(grep 'ROOT_TOKEN  =' ../README.md | awk '{print $NF}')

sleep 2

echo "vault token lookup policies ...."
vault token lookup | grep policies


sleep 2

echo "vault audit enable file  ...."
vault audit enable file file_path=/vault/logs/vault-audit.log
vault audit list
