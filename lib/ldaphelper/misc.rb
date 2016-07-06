require 'net/ldap'
module LitaLDAPHelper
  module Misc
    def client
      puts "config: #{config.bind_dn} with #{config.bind_password}"
      ldap = Net::LDAP.new :host => config.host,
        :port => config.port,
        :auth =>{
          :method => config.auth_method.to_sym,
          :username => config.bind_dn,
          :password => config.bind_password
        }

      if ldap.bind
        ldap
      else
        raise "Cannot connect to ldap server"
      end
    end
  end
end
