# client-ruby

[![Tests](https://github.com/nebhale/client-ruby/workflows/Tests/badge.svg?branch=main)](https://github.com/nebhale/client-ruby/actions/workflows/tests.yaml)
[![codecov](https://codecov.io/gh/nebhale/client-ruby/branch/main/graph/badge.svg)](https://codecov.io/gh/nebhale/client-ruby)

`client-ruby` is a library to access [Service Binding Specification for Kubernetes](https://k8s-service-bindings.github.io/spec/) conformant Service Binding [Workload Projections](https://k8s-service-bindings.github.io/spec/#workload-projection).

## Example

```ruby
require "bindings"
require "pg"

b = Bindings.from_service_binding_root
b = Bindings.filter(b, "postgresql")
raise "Incorrect number of PostgreSQL bindings: #{b.length}" if b.length != 1

u = b[0].get("url")
raise "No URL in binding" if url.nil?

conn = PG.connect(u)

# ...
```

## License

Apache License v2.0: see [LICENSE](./LICENSE) for details.
