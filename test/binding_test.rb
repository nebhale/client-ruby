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
require "binding"

describe "get" do
  it "missing" do
    b = Bindings::HashBinding.new("test-name", {})
    assert_nil b.get("test-secret-key")
  end

  it "valid" do
    b = Bindings::HashBinding.new("test-name",
                                  {
                                    "test-secret-key" => "test-secret-value\n".unpack("U*")
                                  })

    assert_equal "test-secret-value", b.get("test-secret-key")
  end
end

describe "provider" do
  it "missing" do
    b = Bindings::HashBinding.new("test-name", {})
    assert_nil b.provider
  end

  it "valid" do
    b = Bindings::HashBinding.new("test-name",
                                  {
                                    "provider" => "test-provider-1".unpack("U*")
                                  })

    assert_equal "test-provider-1", b.provider
  end
end

describe "type" do
  it "invalid" do
    b = Bindings::HashBinding.new("test-name", {})
    assert_raises { b.type }
  end

  it "valid" do
    b = Bindings::HashBinding.new("test-name",
                                  {
                                    "type" => "test-type-1".unpack("U*")
                                  })

    assert_equal "test-type-1", b.type
  end
end

describe "CacheBinding" do
  it "missing" do
    s = StubBinding.new
    b = Bindings::CacheBinding.new(s)

    assert_nil b.get_as_bytes("test-unknown-key")
    assert_nil b.get_as_bytes("test-unknown-key")
    assert_equal s.get_as_bytes_count, 2
  end

  it "valid" do
    s = StubBinding.new
    b = Bindings::CacheBinding.new(s)

    refute_nil b.get_as_bytes "test-key"
    refute_nil b.get_as_bytes "test-key"
    assert_equal s.get_as_bytes_count, 1
  end

  it "name" do
    s = StubBinding.new
    b = Bindings::CacheBinding.new(s)

    refute_nil b.name
    refute_nil b.name
    assert_equal s.name_count, 2
  end
end

describe "ConfigTreeBinding" do
  it "missing" do
    b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")
    assert_nil b.get_as_bytes("test-missing-key")
  end

  it "directory" do
    b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")
    assert_nil b.get_as_bytes(".hidden-data")
  end

  it "invalid" do
    b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")
    assert_nil b.get_as_bytes("test^invalid^key")
  end

  it "valid" do
    b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")
    assert_equal "test-secret-value\n".unpack("U*"), b.get_as_bytes("test-secret-key")
  end

  it "name" do
    b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")
    assert_equal "test-k8s", b.name
  end
end

describe "HashBinding" do
  it "missing" do
    b = Bindings::HashBinding.new("test-name", {})
    assert_nil b.get_as_bytes("test-missing-key")
  end

  it "invalid" do
    b = Bindings::HashBinding.new("test-name", {})
    assert_nil b.get_as_bytes("test^invalid^key")
  end

  it "valid" do
    b = Bindings::HashBinding.new("test-name",
                                  {
                                    "test-secret-key" => "test-secret-value\n".unpack("U*")
                                  })

    assert_equal "test-secret-value\n".unpack("U*"), b.get_as_bytes("test-secret-key")
  end

  it "name" do
    b = Bindings::HashBinding.new("test-name", {})
    assert_equal "test-name", b.name
  end
end

class StubBinding
  include Bindings::Binding

  attr_reader :get_as_bytes_count, :name_count

  def initialize
    @get_as_bytes_count = 0
    @name_count = 0
  end

  def get_as_bytes(key)
    @get_as_bytes_count += 1

    return "test-value".unpack("U*") if key == "test-key"

    nil
  end

  def name
    @name_count += 1
    "test-name"
  end
end
