require 'rubygems'
require 'bundler/setup'
require 'aws-sdk'
require 'thor'
require 'time'
require 'logger'
require 'json'
require 'base64'
require 'kms'
require 'kms/settings'

module Kms
  class Cli < Thor
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
  	# TODO : move logging to a mixin
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

    desc "encrypt", "Encrypt plaintext with supplied key alias; use product, tenant, stack and context to build encryption context"
  	method_option :tenant, :required => true, :aliases => "-t", :type => :string, :desc => "tenant - name of the tenant of the product"
    method_option :stack, :required => true, :aliases => "-s", :type => :string, :desc => "stack - dev, qa, sit, uat, production"
    method_option :context, :required => true, :aliases => "-c", :type => :string, :desc => "context - unique context for the plaintext being encrypted; for example, hostname of the application server"
    method_option :plaintext, :required => true, :aliases => "-x", :type => :string, :desc => "plaintext - text to be encrypted"
    def encrypt
      @@logger.progname = "#{self.class.name}:#{__method__.to_s}"
  		@@logger.info {"[Start] #{__method__.to_s}"}

      resp = Kms.encrypt(options[:tenant], options[:stack], options[:context], options[:plaintext])
      puts resp
      @@logger.info {"[Stop] #{__method__.to_s}"}
    end

    desc "decrypt", "Decrypt base64 encoded ciphertext with supplied key alias; use tenant, stack and context to build encryption context"
  	method_option :tenant, :required => true, :aliases => "-t", :type => :string, :desc => "tenant - name of the tenant of the product"
    method_option :stack, :required => true, :aliases => "-s", :type => :string, :desc => "stack - dev, qa, sit, uat, production"
    method_option :context, :required => true, :aliases => "-c", :type => :string, :desc => "context - unique context for the plaintext being encrypted; for example, hostname of the application server"
    method_option :ciphertext, :required => true, :aliases => "-x", :type => :string, :desc => "ciphertext - Base64 encoded text to be decrypted"
    def decrypt
      @@logger.progname = "#{self.class.name}:#{__method__.to_s}"
  		@@logger.info {"[Start] #{__method__.to_s}"}      

      resp = Kms.decrypt(options[:tenant], options[:stack], options[:context], options[:ciphertext])
      puts resp
      @@logger.info {"[Stop] #{__method__.to_s}"}
    end

    no_tasks do
      def build_encryption_context(product, tenant, stack, context)
        ec_hash = {
                    :product =>   product,
                    :tenant  =>   tenant,
                    :stack   =>   stack,
                    :context =>   context
                 }
        return JSON.generate(ec_hash).to_json
      end
    end
  end
end
