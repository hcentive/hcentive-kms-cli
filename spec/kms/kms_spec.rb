require 'aws-sdk'
require 'base64'
require 'json'
require 'kms'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe Kms do
  before :all do
    @credentialsfile = File.expand_path(File.join(File.dirname(__FILE__), "..", "fixtures/kms.test.credentials"))
    AWS_REGION = "AWS_REGION"
    @region = ENV[AWS_REGION]
    # move to factory
    @tenant = "phix"
    @stack = "dev"
    @context = "hcus-osx-011.hcentive.com"
    @key_alias = Kms.build_key_alias(@stack, @tenant)
    @encryption_context = Kms.build_encryption_context(@tenant, @stack, @context)
  end

  it "should encrypt plaintext" do
    plaintext = "Qwerty123!"
    c = Kms.encrypt(@tenant, @stack, @context, plaintext)

    creds = Aws::SharedCredentials.new(path: @credentialsfile, profile_name: 'profile-with-decrypt-permissions')
    k = Aws::KMS::Client.new(credentials: creds, region: @region)
    resp = k.decrypt({
      ciphertext_blob: Base64.decode64(c),
      encryption_context: @encryption_context
    })
    pt = resp.plaintext

    expect(pt).to eq(plaintext)
  end

  it "should decrypt ciphertext" do
    plaintext = "Qwerty123!"

    ka = Kms.build_key_alias(@stack, @tenant)
    creds = Aws::SharedCredentials.new(path: @credentialsfile, profile_name: 'profile-with-encrypt-permissions')
    k = Aws::KMS::Client.new(credentials: creds, region: @region)
    resp = k.encrypt({
      key_id: ka,
      plaintext: plaintext,
      encryption_context: @encryption_context
    })

    c = Base64.encode64(resp.ciphertext_blob)
    p = Kms.decrypt(@tenant, @stack, @context, c)

    expect(p).to eq(plaintext)
  end

  it "should fail to decrypt ciphertext with unauthorized user" do
    plaintext = "Qwerty123!"
    c = Kms.encrypt(@tenant, @stack, @context, plaintext)

    creds = Aws::SharedCredentials.new(path: @credentialsfile)
    k = Aws::KMS::Client.new(credentials: creds, region: @region)    

    expect{resp = k.decrypt({
      ciphertext_blob: Base64.decode64(c),
      encryption_context: @encryption_context
    })}.to raise_error(Aws::KMS::Errors::ServiceError)
  end
end
