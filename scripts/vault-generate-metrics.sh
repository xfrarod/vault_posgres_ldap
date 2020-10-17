#!/bin/bash
export VAULT_ADDR="http://127.0.0.1:8200/"
LOGFILE="perfout.log"
rm -f ${LOGFILE}

echo "vault login...."
vault login -no-print  $(grep 'Initial Root Token' .vault-init | awk '{print $NF}')

echo "vault secrets enable .... "
vault secrets enable -version=2 kv
sleep 2

for i in {1..10}
  do
    printf "."
    vault kv put kv/$i-secret-10 id="$(uuidgen)" >> ${LOGFILE} 2>&1
done
echo "generated 10 secrets"
sleep 2
for i in {1..25}
  do
    printf "."
    vault kv put kv/$i-secret-25 id="$(uuidgen)" >> ${LOGFILE} 2>&1
done
echo "generated 25 secrets"
sleep 2
for i in {1..50}
  do
    printf "."
    vault kv put kv/$i-secret-50 id="$(uuidgen)" >> ${LOGFILE} 2>&1
done
echo "generated 50 secrets"
sleep 2

for i in {1..10}
  do
    printf "."
    vault kv put kv/$i-secret-10 id="$(uuidgen)" >> ${LOGFILE} 2>&1
done
echo "updated first 10 secrets"
sleep 2


echo "Token and Leases: Created a sudo policy for tokens"

echo "write admin  policy..."
vault policy write admin - << EOT
// Example admin policy: "admin"

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}
# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}
# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}
# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}
# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}
EOT
echo "done."
sleep 2

echo "write sudo policy..."
vault policy write sudo - << EOT
// Example policy: "sudo"
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
echo "done."
sleep 2

echo "create 10 base policies"
for i in {1..10}
  do
    printf "."
      vault policy write base-$i  - << EOT
// Example policy: "base"
path "secret/data/$i/training_*" {
   capabilities = ["create", "read"]
}
path "secret/data/$i/+/apikey" {
   capabilities = ["create", "read", "update", "delete"]
}
EOT
done
echo "done."

sleep 2
echo "enable userpass auth method"
vault auth enable userpass
echo "done."

sleep 2
echo "add a perfuser user with password vtl-password"
vault write auth/userpass/users/perfuser \
  password=vtl-password \
  token_ttl=120m \
  token_max_ttl=140m \
  token_policies=sudo
echo "done."

sleep 2
echo "login to vault 10 times as the perfuser user"
for i in {1..10}
  do
    printf "."
    vault login \
      -method=userpass \
      username=perfuser \
      password=vtl-password >> ${LOGFILE} 2>&1
done
echo "done."

sleep 2
echo "login to vault 25 times as the perfuser user"
for i in {1..25}
  do
    printf "."
    vault login \
      -method=userpass \
      username=perfuser \
      password=vtl-password >> ${LOGFILE} 2>&1
done
echo "done."

sleep 2
echo "login to vault 50 times as the perfuser user"
for i in {1..50}
  do
    printf "."
    vault login \
      -method=userpass \
      username=perfuser \
      password=vtl-password >> ${LOGFILE} 2>&1
done
echo "done."


sleep 2
echo "use the token auth method to create 200 tokens with default policy and no default TTL values"
for i in {1..200}
  do
    printf "."
    vault token create -policy=default >> ${LOGFILE} 2>&1
done
echo "done."


