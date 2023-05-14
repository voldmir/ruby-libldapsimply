module LIBLDAPSIMPLY
  require_relative "./clib"

  LDAP_NO_SUCH_OBJECT = 0x20
  LDAP_SCOPE_BASE = 0x0000 # to search the object itself
  LDAP_SCOPE_ONELEVEL = 0x0001 # to search the object's immediate children
  LDAP_SCOPE_SUBTREE = 0x0002 # to search the object and all its descendants
  LDAP_SCOPE_DEFAULT = -1

  class Ldap
    attr_reader :login
    attr_reader :passwd
    attr_reader :client_keytab
    attr_reader :error_msg

    include LIBLDAPSIMPLY::CLID

    def initialize(login, passwd: nil, client_keytab: nil, ldapuri: nil)
      @login = login
      @passwd = passwd
      @ldapuri = ldapuri
      @client_keytab = client_keytab
      @ccache = FFI::MemoryPointer.new :pointer
      @ld = FFI::MemoryPointer::NULL
      @error_msg = FFI::MemoryPointer.new :pointer
      @selected = false
      @result = nil
      init()
    end

    def get_last_mess()
      error_msg.get_pointer(0).get_string(0) unless pp_nil?(error_msg)
    end

    def close()
      ENV["KRB5CCNAME"] = nil
      set_raise(ccache_krb5_clean(@ccache.get_pointer(0), @error_msg), "ccache_krb5_clean") unless pp_nil?(@ccache)
    end

    def bind(ldapuri = nil)
      @ld = FFI::MemoryPointer.new :pointer
      set_raise(tool_conn_setup(@ld, ldapuri.nil? ? @ldapuri : ldapuri), "tool_conn_setup")
      @ld = @ld.get_pointer(0)
      set_raise(tool_bind(@ld, @error_msg), "tool_bind")
    end

    def ubind()
      tool_unbind(@ld) unless pp_nil?(@ld)
      @ld = FFI::MemoryPointer::NULL
    end

    def search(base:, filtpatt:, attributes: nil, scope: nil, sizelimit: nil)
      sizelimit ||= -1
      scope ||= LDAP_SCOPE_SUBTREE
      raise(StandardError.new("Not binded")) if pp_nil?(@ld)

      @result = nil
      fetch = ->(dn, attr, val, not_printable) do
        ((@result ||= {})[dn] ||= {})[attr] = (not_printable == 0 ? val : Base64.decode64(val).force_encoding(Encoding::UTF_8))
      end

      set_raise(tool_search(@ld, base, filtpatt,
                            attributes, scope, sizelimit, @error_msg, fetch), "tool_search")
    end

    def fetchall(&interact)
      return nil if interact.nil? or @result.nil?
      (@result ||= {}).each do |key, item|
        interact.call({ "dn" => "#{key}".force_encoding(Encoding::UTF_8) }.merge!((item ||= {})))
      end
      @result = nil
    end

    def delete(dn)
      raise(StandardError.new("Not binded")) if pp_nil?(@ld)
      rc = tool_delete(@ld, dn, @error_msg)
      rc.to_i == LDAP_NO_SUCH_OBJECT ? rc : set_raise(rc, "tool_delete")
    end

    def modify(dn, mods, newentry, delim = ";")
      raise(StandardError.new("Not binded")) if pp_nil?(@ld)
      set_raise(tool_modify(@ld, dn, mods, newentry.to_i, @error_msg, delim), "tool_modify")
    end

    def rename(dn, new_rdn, new_parent = nil)
      raise(StandardError.new("Not binded")) if pp_nil?(@ld)
      set_raise(tool_rename(@ld, dn, new_rdn, new_parent, @error_msg), "tool_rename")
    end

    private

    def init()
      set_raise(ccache_init_krb5_tgt(login, passwd, client_keytab, @ccache, @error_msg), "ccache_init_krb5_tgt")
      ENV["KRB5CCNAME"] = @ccache.get_pointer(0).get_string(0)
    end

    def pp_nil?(p)
      (p == FFI::MemoryPointer::NULL) or (p.get_pointer(0) == FFI::MemoryPointer::NULL)
    end

    def set_raise(rc, func)
      rc.to_i == 0 ? rc : raise(StandardError.new("#{func} (#{rc}): #{get_last_mess()}"))
    end
  end
end
