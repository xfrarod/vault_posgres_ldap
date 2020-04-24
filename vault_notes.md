#SECRETS
##key-value

###Writing
```
$ vault kv put secret/hello foo=world

Success! Data written to: secret/hello
```
```
$ vault kv put secret/hello foo=world excited=yes

Success! Data written to: secret/hello
```
###Reading
```
$ vault kv get secret/hello
===== Data =====
Key        Value
---        -----
excited    yes
foo        world
```
Optional JSON output is very useful for scripts. For example below we use the `jq` tool to extract the value of the excited secret:

```
$ vault kv get -format=json secret/hello
{
  "request_id": "539846ee-28a0-3766-52c1-5dbe811b7dbc",
  "lease_id": "",
  "lease_duration": 604800,
  "renewable": false,
  "data": {
    "excited": "yes",
    "foo": "world"
  },
  "warnings": null
}

$ vault kv get -format=json secret/hello | jq -r .data.excited
yes
```
###Deleting
```
$ vault kv delete secret/hello

Success! Data deleted (if it existed) at: secret/hello
```
###Enabling secret to a different path
```
$ vault secrets enable -path=kv kv

### Is equivalent to:

$ vault secrets enable kv

Success! Enabled the kv secrets engine at: kv/
```
###  Listing secrets
```
$ vault secrets list
Path           Type          Accessor               Description
----           ----          --------               -----------
aws/           aws           aws_d84bd434           n/a
cubbyhole/     cubbyhole     cubbyhole_f4a9d9b7     per-token private secret storage
database/      database      database_41e80730      n/a
identity/      identity      identity_41c10b6b      identity store
kv/            kv            kv_b72b5f70            n/a
postgresql/    postgresql    postgresql_2bb8a449    n/a
secret/        kv            kv_84b82108            key/value secret storage
sys/           system        system_381fa831        system endpoints used for control, policy and debugging
```
###Disabling secrets engine
```
$ vault secrets disable kv/

Success! Disabled the secrets engine (if it existed) at: kv/
```
##Cubbyhole
###Write data
```
$  vault write cubbyhole/my-company name=digitalonus
```
###Read data
```
$ vault read cubbyhole/my-company
Key     Value
---     -----
name    digitalonus
```
###Delete data
```
$ vault delete cubbyhole/my-company
Success! Data deleted (if it existed) at: cubbyhole/my-company
```
#DYNAMIC SECRETS
##aws
```
$ vault secrets enable -path=aws aws

Success! Enabled the aws secrets engine at: aws/
```
###Configure aws engine
```
$ vault write aws/config/root \
    access_key=AKIAI45GLQPBX6CSENIQ \
    secret_key=z1Pdn06b3TnpG9Gwj3ppPSOlAsu08Qw99PUWeB \
    region=us-east-1

Success! Data written to: aws/config/root
```
###Create a role
```
$ vault write aws/roles/my-role \
        credential_type=iam_user \
        policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1426528957000",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
Success! Data written to: aws/roles/my-role
```
###Generating the aws secret
```
$ vault read aws/creds/my-role
Key                Value
---                -----
lease_id           aws/creds/my-role/7qgsZmIyaaBZT4yQboNdFW7a
lease_duration     168h
lease_renewable    true
access_key         AKIAJIKZCPA4R53C3NQQ
secret_key         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
security_token     <nil>
```
###Revoking the aws secret
```
% vault lease revoke aws/creds/my-role/7qgsZmIyaaBZT4yQboNdFW7a
All revocation operations queued successfully!
```
##Postgres
###Enable database secrets
```
$ vault secrets enable database
Success! Enabled the database secrets engine at: database/
```
###Configure postgres plugin
```
$ vault write database/config/myapp \
    plugin_name="postgresql-database-plugin" \
    connection_url="postgresql://postgres:postgres@postgres:5432/myapp?sslmode=disable" \
    allowed_roles="my-role, readonly"
```
###Create a role that maps a name in vault to an SQL statement to execute to create the DB credential
```
$ vault write database/roles/my-role \
    db_name=myapp \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' \
    VALID UNTIL '{{expiration}}'; 
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="3m" \
    max_ttl="1h"
    
Success! Data written to: database/roles/my-role
```
###Generate postgres secret
```
$ vault read /database/creds/my-role

Key                Value
---                -----
lease_id           database/creds/my-role/6E252RJKZOid7rpUxHEeaabT
lease_duration     1m
lease_renewable    true
password           A1a-2mfSG9ClFPjt42Hi
username           v-root-my-role-2PvoHLCRL3mK1kmE3w1J-1544215033
```
You also can generate the sectet via API

```
$ curl --header "X-Vault-Token: ${ROOT_TOKEN}" http://localhost:8200/v1/database/creds/my-role |  jq -r

{
  "request_id": "cc08db9d-a665-0cb6-188d-20cf570d78b1",
  "lease_id": "database/creds/my-role/5OidV08wNZLXkWgYTxR84n3u",
  "renewable": true,
  "lease_duration": 300,
  "data": {
    "password": "A1a-5xXk6hSwUfK3fzYW",
    "username": "v-root-my-role-5njEgQlMloc4vqOZtUA6-1544217564"
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
```
###Renew lease
```
vault lease renew database/creds/my-role/5OidV08wNZLXkWgYTxR84n3u
```
###Revoke lease
```
vault lease revoke database/creds/my-role/5OidV08wNZLXkWgYTxR84n3u
```
###Disable database secrets
```
$ vault secrets disable database
Success! Disabled the secrets engine (if it existed) at: database/
```
#AUTHENTICATION METHODS
Auth methods are always prefixed with `auth/` in their path
##Userpass
```
$ vault auth enable userpass
```
```
$ vault write auth/userpass/users/francisco \
    password=foo \
    policies=admins
```
```
$vault login -method=userpass username=francisco
Password (will be hidden):
Success! You are now authenticated.
```
##Tokens
###Create tokens
By default, this will create a child token of your current token that inherits all the same policies. 

```
$ vault token create
Key                  Value
---                  -----
token                s.6cbVs5i0cdVxna9wERQuHz7O
token_accessor       4p4zBWQtKYHyOvwrOURSgFN9
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```
###Revoke tokens
```
$ vault token revoke s.6cbVs5i0cdVxna9wERQuHz7O
Success! Revoked token (if it existed)
```
##Github
###Help
You can ask for help information about any CLI auth method.

```
$ vault auth help aws

$ vault auth help userpass

$ vault auth help token

$ vault auth help github
```
###Enable GitHub auth method
```
$ vault auth enable -path=github github

Success! Enabled github auth method at: github/
```
###Configure auth method
```
$ vault write auth/github/config organization=digitalonus
Success! Data written to: auth/github/config

% vault write auth/github/map/teams/my-team value=default,my-policy
Success! Data written to: auth/github/map/teams/my-team
```

The first command configures Vault to pull authentication data from the "digitalonus" organization on GitHub. The next command tells Vault to map any users who are members of the team "my-team" (in the hashicorp organization) to map to the policies "default" and "my-policy". These policies do not have to exist in the system yet - Vault will just produce a warning when we login

###List all enabled auth methods and check config of one of them
```
% vault auth list
Path         Type        Accessor                  Description
----         ----        --------                  -----------
approle/     approle     auth_approle_b5eef0f8     n/a
aws/         aws         auth_aws_25ec0300         n/a
github/      github      auth_github_b5c56996      n/a
ldap/        ldap        auth_ldap_9dc0cb7b        n/a
token/       token       auth_token_2a1a4b1e       token based credentials
userpass/    userpass    auth_userpass_17890496    n/a
```
```
% vault read auth/github/config
Key             Value
---             -----
base_url        n/a
max_ttl         0s
organization    digitalonus
ttl             0s
```

#AUDIT
##File Audit Device
```
vault audit enable file file_path=/var/log/vault_audit.log
```

#POLICIES
###Create a policy
```
vault policy write developer -<<EOF
path "secret/training*" {
  capabilities = ["read"]
}
EOF
```
###Policy that allows only read db credentials
```
vault policy write external -<<EOF
path "database/creds/my-role" {
	capabilities = ["read"]
}
EOF
```
###Create userpass user to assign such policy to
```
vault write auth/userpass/users/francisco password=password policies=external
```