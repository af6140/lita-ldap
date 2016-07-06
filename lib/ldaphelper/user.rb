require 'net/ldap'
module LitaLDAPHelper
  module User
    def search_user(str)
      filter_str_templ = "(&#{config.user_search_filter}#{config.user_object_filter})"
      #filter_str_templ = "#{config.user_search_filter}"
      filter_str = filter_str_templ % { s:str}
      puts filter_str

      tree_base = "#{config.user_base_dn},#{config.base_dn}"
      puts "search base_dn : #{tree_base}"
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
