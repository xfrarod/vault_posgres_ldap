#!/bin/bash +x


# vault init
#Unseal Key 1: r6+m5yHvKKA0rtByJkzpkAjZoMWQW8OtSSaerT5Oz2oB
#Unseal Key 2: I/UQGFxcupkCPtIyOSXZSXfC+m/HpmLBKMjHWRrK6wAC
#Unseal Key 3: YqJZXUFQyNyVr7YCnXltGwAvFSMGUGFxeW6XIwSO+mQD
#Unseal Key 4: SFilDY8skeic3fbiYni/c9of5b1aZjkUBmxOI0yq6CcE
#Unseal Key 5: CQ/sSJIg460LTJLSxiQLIa3yCvGbkDqkV8oeWVLu+UMF
#Initial Root Token: 4100d2fd-e457-7c36-c6ef-ed2d84eb33c6
#
#Vault initialized with 5 keys and a key threshold of 3. Please
#securely distribute the above keys. When the Vault is re-sealed,
#restarted, or stopped, you must provide at least 3 of these keys
#to unseal it again.
#
#Vault does not store the master key. Without at least 3 keys,
#your Vault will remain permanently sealed.


#VAULT_ADDR=vault-lb:9000

VAULT_ADDR=http://127.0.0.1:8200

#ROOT_TOKEN='f97872c9-becf-39d2-c42f-0b5ecc979ea6'
ROOT_TOKEN='fc5fbc30-2550-849f-86c1-7c88a98d9cc9'

GITHUB_TOKEN='115d9de87961a51dc1c3974795388e664761db49'

#echo "++++++++++++++++ Check vault status ++++++++++++++++++"
#
#curl \
#    $VAULT_ADDR/v1/sys/seal-status | jq .
#
#echo "++++++++++++++++ List Auth Backends ++++++++++++++++++"
#
#curl \
#    --header "X-Vault-Token: ${ROOT_TOKEN}" \
#    $VAULT_ADDR/v1/sys/auth | jq .


echo "+++++++++ Mount Authentication Backend +++++++++++++++"

echo '{' > payload.json
echo '  "type": "github",' >> payload.json
echo '  "description": "Login with GitHub"' >> payload.json
echo '}' >> payload.json

curl \
    --header "X-Vault-Token: $GITHUB_TOKEN" \
    --request POST \
    --data @payload.json \
    $VAULT_ADDR/v1/sys/auth/github | jq .

#rm payload.json

#echo "+++++++++ Unount Authentication Backend ++++++++++++++"
#
#curl \
#    --header "X-Vault-Token: $ROOT_TOKEN" \
#    --request DELETE \
#    $VAULT_ADDR/v1/sys/auth/my-auth | jq .

#echo "++++++++++++++++ Authenticating vault ++++++++++++++++"
#
#
#echo "++++++++++++++++ Reading vault value +++++++++++++++++"
#
#curl \
#     -H "X-Vault-Token: ${ROOT_TOKEN}" \
#     -X GET $VAULT_ADDR/v1/secret/foo | jq .