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

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "bindings"
require "pg"

b = Bindings.from_service_binding_root
b = Bindings.filter(b, "postgresql")
raise "Incorrect number of PostgreSQL bindings: #{b.length}" if b.length != 1

u = b[0].get("url")
raise "No URL in binding" if url.nil?

conn = PG.connect(u) # rubocop:disable Lint/UselessAssignment

# ...
