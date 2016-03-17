require 'yaml'
require 'kms/deep_symbolizable'

module Kms
  module Settings
    extend self

    @_settings = {}
    attr_reader :_settings

    def load!(hash)
      newsets = hash.deep_symbolize
      deep_merge!(@_settings, newsets)
    end

    def load_from_file!(filename, options = {})
      newsets = YAML::load_file(filename).deep_symbolize
      newsets = newsets[options[:env].to_sym] if \
                                                 options[:env] && \
                                                 newsets[options[:env].to_sym]
      deep_merge!(@_settings, newsets)
      #@_settings.deep_merge(newsets)
    end

    # Deep merging of hashes
    # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
    def deep_merge!(target, data)
      merger = proc{|key, v1, v2|
        Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      target.merge! data, &merger
    end

    def method_missing(name, *args, &block)
      @_settings[name.to_sym] ||
      fail(NoMethodError, "unknown configuration root #{name}", caller)
    end

  end
end
