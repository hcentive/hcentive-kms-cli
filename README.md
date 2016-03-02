hcentive-kms-cli
================
A command line tool to encrypt and decrypt text using AWS KMS. It is part of the toolset for the [overall encryption framework](https://hcentivetech-my.sharepoint.com/personal/satyendra_sharma_hcentive_com/_layouts/15/guestaccess.aspx?guestaccesstoken=1j4waC6Kg%2b90kbnOEiyD8BohYtSvUKuvhfPfj8Atne4%3d&docid=2_17e675c6f293b4a198e2aa50ef7903313).

Installation
------------
System requirements -
* Ruby 2.1.1
* The following packages must be installed on the system -
  * build-essential
  * zlib1g-dev
  * openssl
  * libssl-dev
  * libopenssl-ruby

`hcentive-kms-cli` requires the following environment variables to be present:
```
AWS_ACCESS_KEY_ID='...'
AWS_SECRET_ACCESS_KEY='...'
AWS_REGION='us-east-1'
AWS_KMS_KEY_SPEC=AES_256
```
If this utility is run from an EC2 instance launched with an [IAM role](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html), the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are picked up from instance metadata.

Clone the repository from https://git.demo.hcentive.com/hcentive-kms-cli, and run `bundle install` to install dependencies.

Usage
-----
`hcentive-kms-cli` has the following commands. Type help to get the list of commands.
```
hcentive-kms-cli help                 
Commands:
  hcentive-kms-cli decrypt PRODUCT TENANT STACK CONTEXT KEYALIAS PLAINTEXT -c, --context=CONTEXT -p, --product=PRODUCT -s, --stack=STACK -t, --tenant=TENANT -x, --ciphertext=CIPHERTEXT             ...
  hcentive-kms-cli encrypt PRODUCT TENANT STACK CONTEXT KEYALIAS PLAINTEXT -c, --context=CONTEXT -k, --keyalias=KEYALIAS -p, --product=PRODUCT -s, --stack=STACK -t, --tenant=TENANT -x, --plaintext=...
  hcentive-kms-cli help [COMMAND]
```

* ### hcentive-kms-cli encrypt
Encrypt plaintext with supplied key alias; use product, tenant, stack and context to build encryption context.

###### USAGE
`hcentive-kms-cli encrypt --context=CONTEXT  --keyalias=KEYALIAS --product=PRODUCT --stack=STACK --tenant=TENANT --plaintext=PLAINTEXT`

Or use option aliases.

`hcentive-kms-cli encrypt -c CONTEXT  -k KEYALIAS -p PRODUCT -s STACK -t TENANT -x PLAINTEXT`

###### Options
```
-p, --product=PRODUCT      # product - name of the product for which the password is being encrypted
-t, --tenant=TENANT        # tenant - name of the tenant of the product
-s, --stack=STACK          # stack - dev, qa, sit, uat, production
-c, --context=CONTEXT      # context - unique context for the plaintext being encrypted; for example, hostname of the application server
-k, --keyalias=KEYALIAS    # keyalias - encryption key alias
-x, --plaintext=PLAINTEXT  # plaintext - text to be encrypted
```

* ### hcentive-kms-cli decrypt
Decrypt base64 encoded ciphertext with supplied key alias; use product, tenant, stack and context to build encryption context

###### USAGE
`hcentive-kms-cli decrypt --context=CONTEXT --product=PRODUCT --stack=STACK --tenant=TENANT --ciphertext=CIPHERTEXT`

Or use option aliases.

`hcentive-kms-cli decrypt -c CONTEXT -p PRODUCT -s STACK -t TENANT -x CIPHERTEXT`

###### Options
```
-p, --product=PRODUCT      # product - name of the product for which the password is being encrypted
-t, --tenant=TENANT        # tenant - name of the tenant of the product
-s, --stack=STACK          # stack - dev, qa, sit, uat, production
-c, --context=CONTEXT      # context - unique context for the plaintext being encrypted; for example, hostname of the application server
-k, --keyalias=KEYALIAS    # keyalias - encryption key alias
-x, --plaintext=PLAINTEXT  # plaintext - text to be encrypted
```
