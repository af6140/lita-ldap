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

      #https://dzone.com/articles/matching-quoted-strings-ruby
      #matching quoted string
      route(
        /^ldap\s+check\s+filter\s+(["'])([^\1]+)(\1)$/,
        :cmd_check_filter,
        command: true,
        help: {
          t('help.cmd_check_filter_key') => t('help.cmd_check_filter_value')
        }
      )

      route(
        /^ldap\s+search\s+with\s+filter\s+(["'])([^\1]+)(\1)$/,
        :cmd_search_with_filter,
        command: true,
        help: {
          t('help.cmd_search_with_filter_key') => t('help.cmd_search_with_filter_value')
        }
      )

      route(
        /^ldap\s+show\s+dn\s+(["'])([^\1]+)(\1)$/,
        :cmd_search_with_dn,
        command: true,
        help: {
          t('help.cmd_search_with_dn_key') => t('help.cmd_search_with_dn_value')
        }
      )

      route(
        /^ldap\s+delete\s+dn\s+(["'])([^\1]+)(\1)$/,
        :cmd_delete_with_dn,
        command: true,
        help: {
          t('help.cmd_delete_with_dn_key') => t('help.cmd_delete_with_dn_value')
        }
      )

      route(
        /^ldap\s+delete\s+tree\s+dn\s+(["'])([^\1]+)(\1)$/,
        :cmd_delete_tree_with_dn,
        command: true,
        help: {
          t('help.cmd_delete_tree_with_dn_key') => t('help.cmd_delete_tree_with_dn_value')
        }
      )

      route(
        /^ldap\s+root\s+dse\s*$/,
        :cmd_show_root_dse,
        command: true,
        help: {
          t('help.cmd_show_root_dse_key') => t('help.cmd_show_root_dse_value')
        }
      )


      def cmd_search_user(response)
        search_string = response.matches[0][0]
        #logger.info "searching user with #{search_string}"
        results = search_user(search_string)
        response.reply results
      end

      def cmd_search_group(response)
        search_string = response.matches[0][0]
        #logger.debug "searching group with #{search_string}"
        results = search_group(search_string)
        response.reply results
      end

      def cmd_check_filter(response)
        filter_string = response.matches[0][1]
        #puts "filter_string: #{filter_string}"
        if ! filter_string.nil? && filter_string.strip.length>0
          is_valid = valid_filter?(filter_string)
          if is_valid
            response.reply "Filter is valid."
          else
            response.reply "Filter in not valid."
          end
        else
          response.reply "Filter string is empty."
        end
      end

      def cmd_search_with_filter(response)
        filter_string = response.matches[0][1]
        if ! filter_string.nil? && filter_string.strip.length>0
          is_valid = valid_filter?(filter_string)
          if is_valid
            results = search_with_filter(filter_string)
            response.reply results
          else
            response.reply "Filter in not valid."
          end
        else
          response.reply "Filter string is empty."
        end
      end

      def cmd_search_with_dn(response)
        dn = response.matches[0][1]
        if ! dn.nil? && dn.strip.length>0
          results = get_entry_by_dn(dn)
          response.reply results
        else
          response.reply "Invalid dn provided."
        end
      end

      def cmd_delete_with_dn(response)
        dn = response.matches[0][1]
        if ! dn.nil? && dn.strip.length>0
          begin
            success = delete_entry_by_dn(dn)
            if success
              response.reply "Entry deleted."
            else
              response.reply "Failed to delete entry, server may not support LDAP control 1.2.840.113556.1.4.805."
            end
          rescue Exception => e
            response.reply e.message
          end
        else
          response.reply "Invalid dn provided."
        end
      end

      def cmd_delete_tree_with_dn(response)
        dn = response.matches[0][1]
        if ! dn.nil? && dn.strip.length>0
          begin
            success = delete_tree_by_dn(dn)
            if success
              response.reply "Entry deleted."
            else
              response.reply "Failed to delete entry."
            end
          rescue Exception => e
            response.reply e.message
          end
        else
          response.reply "Invalid dn provided."
        end
      end

      def cmd_show_root_dse(response)
        results = search_root_dse
        response.reply results
      end

      Lita.register_handler(self)
    end #class
  end # module
end #module
