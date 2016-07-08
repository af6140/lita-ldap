require "spec_helper"
require 'docker'

describe Lita::Handlers::Ldap, lita_handler: true do

  before :all do
      @image = Docker::Image.create('fromImage' => 'accenture/adop-ldap:0.1.2')
      #check docker image documentation

      #see docker image documentation
      # some password need to be of complexity
      default_account_settings = [
        'SLAPD_PASSWORD=admin',
        'INITIAL_ADMIN_USER=admin_user',
        'INITIAL_ADMIN_PASSWORD=Jpk66g63ZifGYIcShSGM',
        'GERRIT_PASSWORD=Jpk66g63ZifGYIcShSGM',
        'JENKINS_PASSWORD=Jpk66g63ZifGYIcShSGM',
      ]

      @container = Docker::Container.create( 'Image' => 'accenture/adop-ldap:latest',
        'Env'=> default_account_settings,
        'ExposedPorts' => {
          '389/tcp' => {}
        },
        'HostConfig' => {
          'PortBindings' => { '389/tcp' => [{ 'HostPort' => '1389' }] }
        }
      )
      @container.rename('lita_ldap')
      @container.start
      sleep 5
      #@container.logs(stdout: true)

      puts "****** Start lita_ldap container ******"

  end
  #
  after :all do
    puts "****** Stop lita_ldap container ******"
    @container.stop
    sleep 2
    @container.delete(:force => true)
  end

  before do
    registry.config.handlers.ldap.host = 'localhost'
    registry.config.handlers.ldap.port = 1389
    registry.config.handlers.ldap.bind_dn = 'cn=admin,dc=ldap,dc=example,dc=com'
    registry.config.handlers.ldap.bind_password = 'admin'
    registry.config.handlers.ldap.base_dn = 'dc=ldap,dc=example,dc=com'
    registry.config.handlers.ldap.user_base_dn = 'ou=people'
    registry.config.handlers.ldap.group_base_dn = 'ou=groups'
  end

  it do
    is_expected.to route_command('ldap search user nexus').to(:cmd_search_user)
    is_expected.to route_command('ldap search group nx-admin').to(:cmd_search_group)
    is_expected.to route_command('ldap check filter "cn=admin"').to(:cmd_check_filter)
    is_expected.to route_command('ldap search with filter "cn=nexus"').to(:cmd_search_with_filter)
    is_expected.to route_command("ldap show dn 'dn: cn=nx-admin,ou=groups,dc=ldap,dc=example,dc=com'").to(:cmd_search_with_dn)
    is_expected.to route_command("ldap delete dn 'dn: cn=nx-admin,ou=groups,dc=ldap,dc=example,dc=com'").to(:cmd_delete_with_dn)
    is_expected.to route_command("ldap delete tree dn 'dn: ou=groups,dc=ldap,dc=example,dc=com'").to(:cmd_delete_tree_with_dn)
    is_expected.to route_command('ldap root dse').to(:cmd_show_root_dse)
  end

  describe '#search user' do
    it 'search user' do
      send_command("ldap search user nexus")
      puts replies
    end
  end

  describe '#search group' do
    it 'search group' do
      send_command("ldap search group nx-admin")
      puts replies
    end
  end

  describe '#check filter' do
    it 'validate filter syntax' do
      send_command("ldap check filter '(|(objectclass=user)(objectclass=person)(objectclass=inetOrgPerson)(objectclass=organizationalPerson))'")
      puts replies
    end
  end

  describe '#search with filter' do
    it 'search with filter' do
      send_command("ldap search with filter 'cn=gerrit'")
      puts replies
    end
  end

  describe '#show dn' do
    it 'show entry with specified dn' do
      send_command("ldap show dn 'dn: cn=nx-admin,ou=groups,dc=ldap,dc=example,dc=com'")
      puts "ldap show dn"
      puts replies
    end
  end

  describe '#delete dn' do
    it 'delete entry with specified dn' do
      send_command("ldap delete dn 'dn: cn=nx-admin,ou=groups,dc=ldap,dc=example,dc=com'")
      puts replies
    end
  end

  describe '#delete tree' do
    it 'delete tree with specified dn' do
      send_command("ldap delete dn 'dn: ou=groups,dc=ldap,dc=example,dc=com'")
      puts replies
    end
  end

  describe '#show root dse' do
    it 'show directory root dse' do
      send_command("ldap root dse")
      puts replies
    end
  end
end
