require 'net/ldap'
module LitaLDAPHelper
  module Group
    def search_group(str)
      filter_str_templ = "(&#{config.group_search_filter}#{config.group_object_filter})"
      #filter_str_templ = "#{config.user_search_filter}"
      filter_str = filter_str_templ % { s:str}
      tree_base = "#{config.group_base_dn},#{config.base_dn}"
      puts "search base_dn : #{tree_base} with filter_str #{filter_str}"
      filter=Net::LDAP::Filter.construct(filter_str)
      return_attributes = config.user_attributes || config.default_attributes
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
    end # end function search_usr

  end#Misc
end#LitaLDAPHelper
