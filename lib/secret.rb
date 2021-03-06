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

# A library to access Service Binding Specification for Kubernetes conformant Service Binding Workload Projections.
#
# @see https://k8s-service-bindings.github.io/spec
module Bindings
  # Tests whether a String is a valid Kubernetes Secret key:
  # https://kubernetes.io/docs/concepts/configuration/secret/#overview-of-secrets
  #
  # @param [String] key the key to check
  # @return [boolean] true if the String is a valid Kubernetes Secret key, false otherwise
  def self.valid_secret_key?(key)
    /^[A-Za-z0-9\-_.]+$/.match(key)
  end
end
