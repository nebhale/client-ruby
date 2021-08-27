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

require "test_helper"
require "secret"

describe "valid_secret_key?" do
  it "valid" do
    valid = %w[alpha BRAVO Charlie delta01 echo-foxtrot golf_hotel india.juliet .kilo]
    valid.each { |v| assert Bindings.valid_secret_key?(v) }
  end

  it "invalid" do
    invalid = %w[lima^mike]
    invalid.each { |i| refute Bindings.valid_secret_key?(i) }
  end
end
