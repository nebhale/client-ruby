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

describe "Binding" do
  it "should return string value" do
    b = Bindings::HashBinding.new("test-name",
                                  {
                                    "test-secret-key" => "test-secret-value\n".unpack("U*")
                                  })

    v = b.get("test-secret-key")
    assert_equal "test-secret-value", v
  end

  describe "provider" do
    it "should return nil if provider is not specified" do
      b = Bindings::HashBinding.new("test-name", {})

      v = b.provider
      assert_nil v
    end

    it "should return provider" do
      b = Bindings::HashBinding.new("test-name",
                                    {
                                      "provider" => "test-provider-1".unpack("U*")
                                    })

      v = b.provider
      assert_equal "test-provider-1", v
    end
  end

  describe "type" do
    it "should raise error if type is not specified" do
      b = Bindings::HashBinding.new("test-name", {})

      assert_raises { b.type }
    end

    it "should return provider" do
      b = Bindings::HashBinding.new("test-name",
                                    {
                                      "type" => "test-type-1".unpack("U*")
                                    })

      v = b.type
      assert_equal "test-type-1", v
    end
  end
end

describe "CacheBinding" do
  describe "getAsBytes" do
    it "should retrieve uncached value" do
      s = StubBinding.new
      b = Bindings::CacheBinding.new(s)

      v = b.get_as_bytes "test-key"
      refute_nil v
      assert_equal s.get_as_bytes_count, 1
    end

    it "should not cache unknown keys" do
      s = StubBinding.new
      b = Bindings::CacheBinding.new(s)

      v = b.get_as_bytes "test-unknown-key"
      assert_nil v
      v = b.get_as_bytes "test-unknown-key"
      assert_nil v
      assert_equal s.get_as_bytes_count, 2
    end

    it "should return cached value" do
      s = StubBinding.new
      b = Bindings::CacheBinding.new(s)

      refute_nil b.get_as_bytes "test-key"
      refute_nil b.get_as_bytes "test-key"
      assert_equal s.get_as_bytes_count, 1
    end
  end

  it "should always retrieve name" do
    s = StubBinding.new
    b = Bindings::CacheBinding.new(s)

    refute_nil b.name
    refute_nil b.name
    assert_equal s.name_count, 2
  end
end

describe "ConfigTreeBinding" do
  describe "getAsBytes" do
    it "should return nil for a missing key" do
      b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")

      v = b.get_as_bytes("test-missing-key")
      assert_nil v
    end

    it "should return nil for a directory" do
      b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")

      v = b.get_as_bytes(".hidden-data")
      assert_nil v
    end

    it "should return nil for an invalid key" do
      b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")

      v = b.get_as_bytes("test^missing^key")
      assert_nil v
    end

    it "should return bytes" do
      b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")

      v = b.get_as_bytes("test-secret-key")
      assert_equal "test-secret-value\n".unpack("U*"), v
    end
  end

  it "should return the name" do
    b = Bindings::ConfigTreeBinding.new("test/testdata/test-k8s")

    assert_equal "test-k8s", b.name
  end
end

describe "HashBinding" do
  describe "getAsBytes" do
    it "should return nil for missing key" do
      b = Bindings::HashBinding.new("test-name",
                                    {
                                      "test-secret-key" => "test-secret-value\n".unpack("U*")
                                    })

      v = b.get_as_bytes("test-missing-key")
      assert_nil v
    end

    it "should return nil for an invalid key" do
      b = Bindings::HashBinding.new("test-name",
                                    {
                                      "test-secret-key" => "test-secret-value\n".unpack("U*")
                                    })

      v = b.get_as_bytes("test^invalid^key")
      assert_nil v
    end

    it "should return bytes" do
      b = Bindings::HashBinding.new("test-name",
                                    {
                                      "test-secret-key" => "test-secret-value\n".unpack("U*")
                                    })

      v = b.get_as_bytes("test-secret-key")
      assert_equal "test-secret-value\n".unpack("U*"), v
    end
  end

  it "should return the name" do
    b = Bindings::HashBinding.new("test-name", {})

    v = b.name
    assert_equal "test-name", v
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
