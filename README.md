kms
===
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

`kms` requires the following environment variables to be present:
```
AWS_ACCESS_KEY_ID='...'
AWS_SECRET_ACCESS_KEY='...'
AWS_REGION='us-east-1'
AWS_KMS_KEY_SPEC=AES_256
```
If this utility is run from an EC2 instance launched with an [IAM role](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html), the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are picked up from instance metadata.

Clone the repository from GitHub and run `bundle install` to install dependencies
```
$ git clone https://git.demo.hcentive.com/hcentive-kms-cli
$ bundle install
```

Usage
-----
`kms` has the following commands. Type help to get the list of commands.
```
kms help                 
Commands:
  kms decrypt TENANT STACK CONTEXT KEYALIAS PLAINTEXT -c, --context=CONTEXT -p, --product=PRODUCT -s, --stack=STACK -t, --tenant=TENANT -x, --ciphertext=CIPHERTEXT             ...
  kms encrypt TENANT STACK CONTEXT KEYALIAS PLAINTEXT -c, --context=CONTEXT -k, --keyalias=KEYALIAS -p, --product=PRODUCT -s, --stack=STACK -t, --tenant=TENANT -x, --plaintext=...
  kms help [COMMAND]
```

* ### kms encrypt
Encrypt plaintext with supplied key alias; use tenant, stack and context to build encryption context.

###### USAGE
`kms encrypt --context=CONTEXT  --keyalias=KEYALIAS --stack=STACK --tenant=TENANT --plaintext=PLAINTEXT`

Or use option aliases.

`kms encrypt -c CONTEXT  -k KEYALIAS -s STACK -t TENANT -x PLAINTEXT`

###### Options
```
-t, --tenant=TENANT        # tenant - name of the tenant of the product
-s, --stack=STACK          # stack - dev, qa, sit, uat, production
-c, --context=CONTEXT      # context - unique context for the plaintext being encrypted; for example, hostname of the application server
-k, --keyalias=KEYALIAS    # keyalias - encryption key alias
-x, --plaintext=PLAINTEXT  # plaintext - text to be encrypted
```

* ### kms decrypt
Decrypt base64 encoded ciphertext with supplied key alias; use tenant, stack and context to build encryption context

###### USAGE
`kms decrypt --context=CONTEXT --stack=STACK --tenant=TENANT --ciphertext=CIPHERTEXT`

Or use option aliases.

`kms decrypt -c CONTEXT -s STACK -t TENANT -x CIPHERTEXT`

###### Options
```
-t, --tenant=TENANT        # tenant - name of the tenant of the product
-s, --stack=STACK          # stack - dev, qa, sit, uat, production
-c, --context=CONTEXT      # context - unique context for the plaintext being encrypted; for example, hostname of the application server
-k, --keyalias=KEYALIAS    # keyalias - encryption key alias
-x, --plaintext=PLAINTEXT  # plaintext - text to be encrypted
```
