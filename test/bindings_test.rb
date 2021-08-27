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

describe "cached" do
  it "cached" do
    b = Bindings.cached([
                          Bindings::HashBinding.new("test-name-1", {}),
                          Bindings::HashBinding.new("test-name-2", {})
                        ])

    b.each { |c| assert c.is_a?(Bindings::CacheBinding) }
  end
end

describe "from" do
  it "missing" do
    assert_predicate Bindings.from_path("missing"), :empty?
  end

  it "file" do
    assert_predicate Bindings.from_path("test/testdata/additional-file"), :empty?
  end

  it "valid" do
    assert_equal 3, Bindings.from_path("test/testdata").length
  end
end

describe "from_service_binding_root" do
  it "unset" do
    assert_predicate Bindings.from_service_binding_root, :empty?
  end

  it "set" do
    old = ENV["SERVICE_BINDING_ROOT"]
    ENV["SERVICE_BINDING_ROOT"] = "test/testdata"

    begin
      assert_equal 3, Bindings.from_service_binding_root.length
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
  it "missing" do
    b = [
      Bindings::HashBinding.new("test-name-1", {})
    ]

    assert_nil Bindings.find(b, "test-name-2")
  end

  it "valid" do
    b = [
      Bindings::HashBinding.new("test-name-1", {}),
      Bindings::HashBinding.new("test-name-2", {})
    ]

    assert_equal "test-name-1", Bindings.find(b, "test-name-1").name
  end
end

describe "filter" do
  it "none" do
    b = [
      Bindings::HashBinding.new("test-name-1",
                                {
                                  "type" => "test-type-1".unpack("U*"),
                                  "provider" => "test-provider-1".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-2",
                                {
                                  "type" => "test-type-1".unpack("U*"),
                                  "provider" => "test-provider-2".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-3",
                                {
                                  "type" => "test-type-2".unpack("U*"),
                                  "provider" => "test-provider-2".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-4",
                                {
                                  "type" => "test-type-2".unpack("U*")
                                })
    ]

    assert_equal 4, Bindings.filter(b).length
  end

  it "type" do
    b = [
      Bindings::HashBinding.new("test-name-1",
                                {
                                  "type" => "test-type-1".unpack("U*"),
                                  "provider" => "test-provider-1".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-2",
                                {
                                  "type" => "test-type-1".unpack("U*"),
                                  "provider" => "test-provider-2".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-3",
                                {
                                  "type" => "test-type-2".unpack("U*"),
                                  "provider" => "test-provider-2".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-4",
                                {
                                  "type" => "test-type-2".unpack("U*")
                                })
    ]

    assert_equal 2, Bindings.filter(b, "test-type-1").length
  end

  it "provider" do
    b = [
      Bindings::HashBinding.new("test-name-1",
                                {
                                  "type" => "test-type-1".unpack("U*"),
                                  "provider" => "test-provider-1".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-2",
                                {
                                  "type" => "test-type-1".unpack("U*"),
                                  "provider" => "test-provider-2".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-3",
                                {
                                  "type" => "test-type-2".unpack("U*"),
                                  "provider" => "test-provider-2".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-4",
                                {
                                  "type" => "test-type-2".unpack("U*")
                                })
    ]

    assert_equal 2, Bindings.filter(b, nil, "test-provider-2").length
  end

  it "type and provider" do
    b = [
      Bindings::HashBinding.new("test-name-1",
                                {
                                  "type" => "test-type-1".unpack("U*"),
                                  "provider" => "test-provider-1".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-2",
                                {
                                  "type" => "test-type-1".unpack("U*"),
                                  "provider" => "test-provider-2".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-3",
                                {
                                  "type" => "test-type-2".unpack("U*"),
                                  "provider" => "test-provider-2".unpack("U*")
                                }),
      Bindings::HashBinding.new("test-name-4",
                                {
                                  "type" => "test-type-2".unpack("U*")
                                })
    ]

    assert_equal 1, Bindings.filter(b, "test-type-1", "test-provider-1").length
  end
end
