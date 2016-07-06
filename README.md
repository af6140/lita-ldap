# lita-ldap

Lita handler for ldap operations.
## Installation

Add lita-ldap to your Lita instance's Gemfile:

``` ruby
gem "lita-ldap"
```

## Configuration

```ruby
Lita.configure do |config|
  config.handlers.ldap.host = 'localhost'
  config.handlers.ldap.port = 1389
  config.handlers.ldap.bind_dn = 'cn=admin,dc=ldap,dc=example,dc=com'
  config.handlers.ldap.bind_password = 'admin'
  config.handlers.ldap.base_dn = 'dc=ldap,dc=example,dc=com'
  config.handlers.ldap.user_base_dn = 'ou=people' # append before base_dn
  config.handlers.ldap.group_base_dn = 'ou=groups' # append before base_dn
end
```

## Usage

* lita search user nexus
* lita search group nx-admin
