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

require "binding"

# A library to access Service Binding Specification for Kubernetes conformant Service Binding Workload Projections.
#
# @see https://k8s-service-bindings.github.io/spec
module Bindings
  # The name of the environment variable read to determine the bindings filesystem root.  Specified by the Kubernetes
  # Service Binding Specification: https://github.com/k8s-service-bindings/spec#workload-projection
  SERVICE_BINDING_ROOT = "SERVICE_BINDING_ROOT"

  # Wraps each Bindings::Binding in a Bindings::CacheBinding.
  #
  # @param [Array<Bindings::Binding>] bindings the bindings to wrap
  # @return [Array<Bindings::Binding>] the wrapped bindings
  def self.cached(bindings)
    bindings.map { |v| Bindings::CacheBinding.new(v) }
  end

  # Creates a new collection of Bindings::Binding's using the specified root.  If the directory does not exist, an
  # empty collection is returned.
  #
  # @param [String] root the root to populate the bindings from
  # @return [Array<Bindings::Binding>] the bindings found in the root
  def self.from_path(root)
    return [] unless File.exist?(root) && File.directory?(root)

    Pathname.new(root).children.each_with_object([]) do |c, b|
      b.append(ConfigTreeBinding.new(c.to_s)) if File.directory?(c)
    end
  end

  # Creates a new collection of Bindings::Binding's using the +$SERVICE_BINDING_ROOT+ environment variable to determine
  # system root.  If the +$SERVICE_BINDING_ROOT+ environment variable is not set, an empty collection is returned.  If
  # the directory does not exist, an empty collection is returned.
  #
  # @return [Array<Bindings::Binding>] the bindings found in $SERVICE_BINDING_ROOT
  def self.from_service_binding_root
    return [] unless ENV.key?(SERVICE_BINDING_ROOT)

    from_path(ENV[SERVICE_BINDING_ROOT])
  end

  # Returns a Bindings::Binding with a given name.  Comparison is case-insensitive.
  #
  # @param [Array<Bindings::Binding>] bindings the bindings to find in
  # @param [String] name the name of the binding to find
  # @return [Bindings::Binding] the binding with a given name if it exists
  # @return [nil]
  def self.find(bindings, name)
    bindings.each do |b|
      return b if b.name.casecmp?(name)
    end

    nil
  end

  # Returns zero or more Bindings with a given type and provider.  If type or provider are None, the result is not
  # filter on that argument.  Comparisons are case-insensitive.
  #
  # @param [Array<Bindings::Binding>] bindings the bindings to filter
  # @param [String] type the type of the binding to find
  # @param [nil] type
  # @param [String] provider the provider of the binding to find
  # @param [nil] provider
  # @return [Array<Bindings::Binding>] the collection of bindings ith a given type and provider
  def self.filter(bindings, type = nil, provider = nil)
    match = []

    bindings.each do |b|
      next unless type.nil? || type_matches?(b, type)
      next unless provider.nil? || provider_matches?(b, provider)

      match.append(b)
    end

    match
  end

  def self.provider_matches?(binding, provider)
    p = binding.provider
    !p.nil? && p.casecmp?(provider)
  end

  def self.type_matches?(binding, type)
    t = binding.type
    !t.nil? && t.casecmp?(type)
  end

  private_class_method :provider_matches?, :type_matches?
end
