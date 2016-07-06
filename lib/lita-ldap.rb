require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]


require 'ldaphelper/misc.rb'
require 'ldaphelper/user.rb'
require 'ldaphelper/group.rb'
require "lita/handlers/ldap"

Lita::Handlers::Ldap.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
