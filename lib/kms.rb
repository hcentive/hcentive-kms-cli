require 'aws-sdk'
require 'time'
require 'logger'
require 'json'
require 'base64'
require 'kms/settings'

# Module with methods for KMS operations.
module Kms
  config = {
    :logger => {
      :home => "/var/log/kms-encrypt/",
      :file => "hcentive-kms.log"
    },
    :aws => {
      :region => "us-east-1"
    },
    :kms => {
      :tld => "net",
      :sld => "hcinternal"
    }
  }

  Kms::Settings.load!(config)
  loghome = Kms::Settings.logger[:home]
	Dir.mkdir(loghome) unless Dir.exist?(loghome)
	loghome.concat(Kms::Settings.logger[:file])
	logfile = File.open(loghome, "a+")
	@@logger = Logger.new(logfile, 'daily')
	@@logger = Logger.new(logfile, 'weekly')
	@@logger = Logger.new(logfile, 'monthly')
	@@logger.level = Logger::INFO
	@@logger.formatter = proc do |severity, datetime, progname, msg|
		"[#{datetime}] : #{severity} : #{progname} - #{msg}\n"
	end

  # Encrypt the supplied plaintext using an encryption context built from the specified tenant, stack and context.
  # @param tenant [String] tenant that owns the master key e.g. "fidelity", "arshop", etc.
  # @param stack [String] stack or environment type for the tenant e.g. "dev", "qa", "prod"
  # @param context [String] context for plaintext to be encrypted. For example, the hostname of a tomcat instance - "fidelity-qa01.hcinternal.net"
  # @param plaintext [String] the plaintext that is to be encrypted.
  # @return [String] base64 encoded ciphertext.
  def self.encrypt(tenant, stack, context, plaintext)
    @@logger.progname = "#{self.class.name}:#{__method__.to_s}"
		@@logger.info {"[Start] #{__method__.to_s}"}

    ciphertext = ''
    begin
      kms = Aws::KMS::Client.new(region: Settings.aws[:region])
      ka = build_key_alias(stack, tenant)
      ec = build_encryption_context(tenant, stack, context)
      resp = kms.encrypt({
        key_id: ka,
        plaintext: plaintext,
        encryption_context: ec
      })
      ciphertext = Base64.encode64(resp.ciphertext_blob)
    rescue Aws::KMS::Errors::ServiceError, Aws::Errors::MissingCredentialsError => e
      @@logger.error "KMS startup failed - #{e.message}"
      e.backtrace.each { |line| @@logger.error line }
      raise e
    ensure
      @@logger.info {"Instantiating KMS"}
    end
    @@logger.info {"[Stop] #{__method__.to_s}"}
    return ciphertext
  end

  # Decrypt the supplied ciphertext using an encryption context built from the specified tenant, stack and context.
  # @param tenant [String] tenant that owns the master key e.g. "fidelity", "arshop", etc.
  # @param stack [String] stack or environment type for the tenant e.g. "dev", "qa", "prod"
  # @param context [String] context for plaintext to be encrypted. For example, the hostname of a tomcat instance - "fidelity-qa01.hcinternal.net"
  # @param ciphertext [String] base64 encoded ciphertext.
  # @return [String] the decrypted plaintext.
  def self.decrypt(tenant, stack, context, ciphertext)
    @@logger.progname = "#{self.class.name}:#{__method__.to_s}"
    @@logger.info {"[Start] #{__method__.to_s}"}

    plaintext = ''
    begin
      kms = Aws::KMS::Client.new(region: Settings.aws[:region])
      ec = build_encryption_context(tenant, stack, context)
      resp = kms.decrypt({
        ciphertext_blob: Base64.decode64(ciphertext),
        encryption_context: ec
      })
      plaintext = resp.plaintext
    rescue Aws::KMS::Errors::ServiceError, Aws::Errors::MissingCredentialsError => e
      @@logger.error "KMS startup failed - #{e.message}"
      e.backtrace.each { |line| @@logger.error line }
      raise e
    ensure
      @@logger.info {"Instantiating KMS"}
    end
    @@logger.info {"[Stop] #{__method__.to_s}"}
    return plaintext
  end

  # Builds encryption context [Hash] from the specified tenant, stack and context.
  # @param tenant [String] tenant that owns the master key e.g. "fidelity", "arshop", etc.
  # @param stack [String] stack or environment type for the tenant e.g. "dev", "qa", "prod"
  # @param context [String] context for plaintext to be encrypted. For example, the hostname of a tomcat instance - "fidelity-qa01.hcinternal.net"
  # @return [Hash].
  def self.build_encryption_context(tenant, stack, context)
    ec_hash = {
                :tenant  =>   tenant,
                :stack   =>   stack,
                :context =>   context
             }
    return ec_hash
  end

  # Builds KMS key alias from stack and tenant.
  # @param tenant [String] tenant that owns the master key e.g. "fidelity", "arshop", etc.
  # @param stack [String] stack or environment type for the tenant e.g. "dev", "qa", "prod"
  # @return [String].
  def self.build_key_alias(stack, tenant)
    ka = "alias/#{Settings.kms[:tld]}/#{Settings.kms[:sld]}/#{stack}/#{tenant}"
    return ka
  end
end
