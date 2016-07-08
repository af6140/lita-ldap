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

    def valid_filter?(filter_str)
      begin
        filter=Net::LDAP::Filter.construct(filter_str)
        true
      rescue Exception => e
        false
      end
    end

    def search_with_filter(filter_str)
      tree_base = "#{config.base_dn}"
      puts "search base_dn : #{tree_base}"
      filter=Net::LDAP::Filter.construct(filter_str)
      return_attributes = config.default_attributes || '*'
      return_attributes = return_attributes.split(',')
      entries = client.search(:base => tree_base, :filter => filter, :attributes =>return_attributes , :return_result => true)
      results = []
      unless entries.nil?
        entries.each do |entry|
          results << entry.to_ldif
          results << '*********'
        end
      end
      #puts results
      results
    end

    def get_entry_by_dn(dn)
      dn_spec = dn.split(':',2)
      dn_str = dn_spec[0]
      if dn_spec.length>1
        dn_str = dn_spec[1]
      end
      dn_str = dn_str.strip
      entries = client.search(:base => dn_str, :filter => nil, :attributes =>['*'] , :return_result => true)
      results = []
      unless entries.nil?
        entries.each do |entry|
          results << entry.to_ldif
          results << '*********'
        end
      end
      #puts results
      results
    end

    def delete_entry_by_dn(dn)
      dn_spec = dn.split(':',2)
      dn_str = dn_spec[0]
      if dn_spec.length>1
        dn_str = dn_spec[1]
      end
      dn_str = dn_str.strip
      client.delete :dn => dn_str
    end

    def delete_tree_by_dn(dn)
      dn_spec = dn.split(':',2)
      dn_str = dn_spec[0]
      if dn_spec.length>1
        dn_str = dn_spec[1]
      end
      dn_str = dn_str.strip
      client.delete :dn => dn_str
    end

    def search_root_dse
      begin
        info = client.search_root_dse
        if info
          info.to_ldif
        end
      rescue Exception => e
        e.message
      end
    end

  end#module misc
end#module LitaLDAPHelper
