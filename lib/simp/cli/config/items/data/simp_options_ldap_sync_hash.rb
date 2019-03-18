require_relative '../item'
require_relative '../../utils'

module Simp; end
class Simp::Cli; end
module Simp::Cli::Config
  class Item::SimpOptionsLdapSyncHash < Item
    def initialize
      super
      @key         = 'simp_options::ldap::sync_hash'
      @description = %Q{}
      @skip_query  = true # generated from another Item, so no query required
    end

    def get_recommended_value
      encrypt( get_item( 'simp_options::ldap::sync_pw' ).value )
    end

    def encrypt( string, salt=nil )
      Simp::Cli::Config::Utils.encrypt_openldap_hash( string, salt )
    end

    def validate( x )
      result = Simp::Cli::Config::Utils.validate_openldap_hash( x )

      # in case the value is pre-assigned, make sure the
      # hash matches the LDAP Bind password
      result && Simp::Cli::Config::Utils.check_openldap_password(
        get_item( 'simp_options::ldap::sync_pw' ).value, x )
    end
  end
end
