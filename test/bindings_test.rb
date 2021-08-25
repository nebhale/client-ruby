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
require "bindings"

describe "Bindings" do
  describe "cached" do
    it "should wrap with CacheBinding" do
      b = Bindings.cached([
                            Bindings::HashBinding.new("test-name-1", {}),
                            Bindings::HashBinding.new("test-name-2", {})
                          ])

      b.each { |c| assert c.is_a?(Bindings::CacheBinding) }
    end
  end

  describe "from" do
    it "should create empty Bindings if directory does not exist" do
      v = Bindings.from_path("missing")
      assert_predicate v, :empty?
    end

    it "should create empty bindings if not a directory" do
      v = Bindings.from_path("test/testdata/additional-file")
      assert_predicate v, :empty?
    end

    it "should create Bindings" do
      v = Bindings.from_path("test/testdata")
      assert_equal 3, v.length
    end
  end

  describe "from_service_binding_root" do
    it "should create empty Bindings if $SERVICE_BINDING_ROOT is not set" do
      v = Bindings.from_service_binding_root
      assert_predicate v, :empty?
    end

    it "should create Bindings" do
      old = ENV["SERVICE_BINDING_ROOT"]
      ENV["SERVICE_BINDING_ROOT"] = "test/testdata"

      begin
        v = Bindings.from_service_binding_root
        assert_equal 3, v.length
      ensure
        if old.nil?
          ENV.delete("SERVICE_BINDING_ROOT")
        else
          ENV["SERVICE_BINDING_ROOT"] = old
        end
      end
    end
  end

  describe "find" do
    it "should return nil if no Binding with name exists" do
      b = [
        Bindings::HashBinding.new("test-name-1", {})
      ]

      assert_nil Bindings.find(b, "test-name-2")
    end

    it "should return Binding" do
      b = [
        Bindings::HashBinding.new("test-name-1", {})
      ]

      refute_nil Bindings.find(b, "test-name-1")
    end
  end

  describe "filter" do
    it "should return no Bindings" do
      b = [
        Bindings::HashBinding.new("test-name-1",
                                  {
                                    "type" => "test-type-1".unpack("U*"),
                                    "provider" => "test-provider-1".unpack("U*")
                                  }),
        Bindings::HashBinding.new("test-name-2",
                                  {
                                    "type" => "test-type-2".unpack("U*")
                                  })
      ]

      v = Bindings.filter(b, "test-type-3")
      assert_predicate v, :empty?
    end

    it "should return a single Binding" do
      b = [
        Bindings::HashBinding.new("test-name-1",
                                  {
                                    "type" => "test-type-1".unpack("U*"),
                                    "provider" => "test-provider-1".unpack("U*")
                                  }),
        Bindings::HashBinding.new("test-name-2",
                                  {
                                    "type" => "test-type-2".unpack("U*")
                                  })
      ]

      v = Bindings.filter(b, "test-type-1")
      assert_equal 1, v.length
    end

    it "should return multiple Bindings" do
      b = [
        Bindings::HashBinding.new("test-name-1",
                                  {
                                    "type" => "test-type-1".unpack("U*"),
                                    "provider" => "test-provider-1".unpack("U*")
                                  }),
        Bindings::HashBinding.new("test-name-2",
                                  {
                                    "type" => "test-type-1".unpack("U*")
                                  })
      ]

      v = Bindings.filter(b, "test-type-1")
      assert_equal 2, v.length
    end

    it "should filter by type and provider" do
      b = [
        Bindings::HashBinding.new("test-name-1",
                                  {
                                    "type" => "test-type-1".unpack("U*"),
                                    "provider" => "test-provider-1".unpack("U*")
                                  }),
        Bindings::HashBinding.new("test-name-2",
                                  {
                                    "type" => "test-type-2".unpack("U*"),
                                    "provider" => "test-provider-2".unpack("U*")
                                  })
      ]

      v = Bindings.filter(b, "test-type-1", "test-provider-1")
      assert_equal 1, v.length
    end

    it "should filter by provider" do
      b = [
        Bindings::HashBinding.new("test-name-1",
                                  {
                                    "type" => "test-type-1".unpack("U*"),
                                    "provider" => "test-provider-1".unpack("U*")
                                  }),
        Bindings::HashBinding.new("test-name-2",
                                  {
                                    "type" => "test-type-2".unpack("U*"),
                                    "provider" => "test-provider-2".unpack("U*")
                                  })
      ]

      v = Bindings.filter(b, "test-type-1", "test-provider-1")
      assert_equal 1, v.length
    end
  end
end
