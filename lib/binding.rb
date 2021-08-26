# frozen_string_literal: true

# Copyright 2021 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "secret"

# A library to access Service Binding Specification for Kubernetes conformant Service Binding Workload Projections.
#
# @see https://k8s-service-bindings.github.io/spec
module Bindings
  # The key for the provider of a binding
  PROVIDER = "provider"

  # The key for the type of a binding
  TYPE = "type"

  # A representation of a binding as defined by the Kubernetes Service Binding Specification:
  # https://github.com/k8s-service-bindings/spec#workload-projection
  module Binding
    # Returns the contents of a binding entry in its raw bytes form.
    #
    # @param [String] _key the key of the entry to retrieve
    # @return [String] the contents of a binding entry if it exists
    # @return [nil]
    def get_as_bytes(_key)
      raise "unimplemented"
    end

    # Returns the name of the binding
    #
    # @return [String] the name of the binding
    def name
      raise "unimplemented"
    end

    # Returns the contents of a binding entry as a UTF-8 decoded String.  Any whitespace is trimmed.
    #
    # @param [String] key the key of the entry to retrieve
    # @return [String] the contents of a binding entry as a UTF-8 decoded String if it exists
    # @return [nil]
    def get(key)
      b = get_as_bytes(key)

      return nil if b.nil?

      b.pack("U*").strip
    end

    # Returns the value of the PROVIDER key
    #
    # @return [String] the value of the PROVIDER key if it exists
    # @return [nil]
    def provider
      get(PROVIDER)
    end

    # Returns the value of the TYPE key.
    #
    # @return [String] the value of the TYPE key
    def type
      t = get(TYPE)

      raise "binding codes not contain a type" if t.nil?

      t
    end
  end

  # An implementation of Bindings::Binding that caches values once they've been retrieved.
  class CacheBinding
    include Binding

    # Creates a new instance.
    #
    # @param [Bindings::Binding] delegate the Binding used to retrieve original values
    def initialize(delegate)
      @delegate = delegate
      @cache = {}
      @mutex = Mutex.new
    end

    # Returns the contents of a binding entry in its raw bytes form.
    #
    # @param [String] key the key of the entry to retrieve
    # @return [String] the contents of a binding entry if it exists
    # @return [nil]
    def get_as_bytes(key)
      @mutex.synchronize do
        return @cache[key] if @cache.key?(key)

        v = @delegate.get_as_bytes(key)
        @cache[key] = v unless v.nil?

        v
      end
    end

    # Returns the name of the binding
    #
    # @return [String] the name of the binding
    def name
      @delegate.name
    end
  end

  # An implementation of Bindings::Binding that reads files from a volume mounted Kubernetes Secret:
  # https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets
  class ConfigTreeBinding
    include Binding

    # Creates a new instance.
    #
    # @param [String] root the root of the volume mounted Kubernetes Secret
    def initialize(root)
      @root = root
    end

    # Returns the contents of a binding entry in its raw bytes form.
    #
    # @param [String] key the key of the entry to retrieve
    # @return [Array<Integer>] the contents of a binding entry if it exists
    # @return [nil]
    def get_as_bytes(key)
      return nil unless Bindings.valid_secret_key?(key)

      p = File.join(@root, key)

      return nil unless File.exist?(p) && File.file?(p)

      File.read(p, mode: "rb").bytes
    end

    # Returns the name of the binding
    #
    # @return [String] the name of the binding
    def name
      File.basename(@root)
    end
  end

  # An implementation of Bindings::Binding that returns values from a [Hash].
  class HashBinding
    include Binding

    # @!attribute [r] name
    #   @return [String] the name of the binding
    attr_reader :name

    # Creates a new instance.
    #
    # @param [String] name the name of the binding
    # @param [Hash<String, String>] content the content of the binding
    def initialize(name, content)
      @name = name
      @content = content
    end

    # Returns the contents of a binding entry in its raw bytes form.
    #
    # @param [String] key the key of the entry to retrieve
    # @return [String] the contents of a binding entry if it exists
    # @return [nil]
    def get_as_bytes(key)
      return nil unless Bindings.valid_secret_key?(key)
      return nil unless @content.key?(key)

      @content[key]
    end
  end
end
