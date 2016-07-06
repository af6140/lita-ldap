# require 'rubygems'
# require 'net/ldap'

module Lita
  module Handlers
    class Ldap < Handler
      # insert handler code here
      namespace 'Ldap'

      config :host, required: true, type: String
      config :port, required: false, type: Integer, default: 389
      config :bind_dn, required: true, type: String
      config :bind_password, required: true, type: String
      config :auth_method, required: false, type: String, default: 'simple'
      #     encryption = {
      #       :method => :start_tls,
      #       :tls_options => { :ca_file => "/etc/cafile.pem", :ssl_version => "TLSv1_1" }
      #     }
      config :encryption, required: false, type: Hash, default: {}

      config :base_dn, required: true, type: String
      config :user_base_dn, required: true, type: String #ou=people, dc=example,dc=net
      config :username_attribute, required: false, type: String, default: 'uid'
      config :default_attributes, required: false, type: String, default: 'dc,o,ou,cn,uid,mail,member,uniquemember,memberof,sAMAccountName, primaryGroupToken,primaryGroupID'
      config :user_object_filter, required: false, type: String, default: '(|(objectclass=user)(objectclass=person)(objectclass=inetOrgPerson)(objectclass=organizationalPerson))'
      config :user_search_filter, required: true, type: String, default: '(|(cn=%{s})(uid=%{s})(userPrincipalName=%{s})(mail=%{s}))'
      config :user_member_attributes, required: false, type: String, default: 'memberof,primaryGroupID'
      config :user_attributes, required: false, type: String,  default: 'dn,cn,uid,mail, member, memberof,sn,givenName,loginshell,homedirectory, gidNumber,title,uidNumber,gecos,objectclass'

      config :group_base_dn, required: true, type: String #ou=group, dc=example,dc=net
      config :group_object_filter, required: false, type: String, default: '(|(objectclass=group)(objectclass=groupofnames) (objectclass=groupofuniquenames))'
      config :group_search_filter, required: false, type: String, default: '(|(o=%{s})(ou=%{s})(cn=%{s}))'
      config :group_member_attributes, required: false, type: String, default: 'member, uniquemember'


      include ::LitaLDAPHelper::Misc
      include ::LitaLDAPHelper::User
      include ::LitaLDAPHelper::Group

      route(
       /^ldap\s+search\s+user\s+(\S+)$/,
       :cmd_search_user,
       command: true,
       help: {
         t('help.cmd_search_user_key') => t('help.cmd_search_user_value')
       }
      )

      route(
       /^ldap\s+search\s+group\s+(\S+)$/,
       :cmd_search_group,
       command: true,
       help: {
         t('help.cmd_search_group_key') => t('help.cmd_search_group_value')
       }
      )

      def cmd_search_user(response)
        search_string = response.matches[0][0]
        puts "searching user with #{search_string}"
        results = search_user(search_string)
        response.reply results
      end

      def cmd_search_group(response)
        search_string = response.matches[0][0]
        puts "searching user with #{search_string}"
        results = search_group(search_string)
        response.reply results
      end

      Lita.register_handler(self)
    end #class
  end # module
end #module
