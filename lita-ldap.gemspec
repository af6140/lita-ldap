Gem::Specification.new do |spec|
  spec.name          = "lita-ldap"
  spec.version       = "0.1.0"
  spec.authors       = ["Wang, Dawei"]
  spec.email         = ["daweiwang.gatekeeper@gmail.com"]
  spec.description   = "LDAP operations"
  spec.summary       = "LDAP operations"
  spec.homepage      = "https://github.com/af6140/lita-ldap"
  spec.license       = "Apache-2.0"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rack", "~> 1.6"
  spec.add_runtime_dependency "lita", ">= 4.7"
  spec.add_runtime_dependency 'net-ldap', ">= 0.14"

  spec.add_development_dependency "bundler", "~> 1.3"
  #spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  #spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "docker-api"
end
