module LIBLDAPSIMPLY
  module CLID
    extend FFI::Library
    ffi_lib "libldapsimply.so", FFI::Library::LIBC
    #
    #int tool_conn_setup(LDAP **ld, char *ldapuri);
    attach_function :tool_conn_setup, [:pointer, :string], :int
    #int tool_bind(LDAP *ldd, char **error_msg);
    attach_function :tool_bind, [:pointer, :pointer], :int
    #typedef void(LDAP_RESULT_INTERACT_PROC)(char *dn, char *attr, char *val, int not_printable);
    callback :search_interact, [:string, :string, :string, :int], :void
    #int tool_search(LDAP *ld,
    #            char *base,
    #            char *filtpatt,
    #            char *attributes,
    #            int scope,
    #            int sizelimit,
    #            char **error_msg,
    #            LDAP_RESULT_INTERACT_PROC *interact);
    attach_function :tool_search, [:pointer,
                                   :string,
                                   :string,
                                   :string,
                                   :int,
                                   :int,
                                   :pointer,
                                   :search_interact], :int
    #int tool_delete(LDAP *ld, const char *dn, char **error_msg);
    attach_function :tool_delete, [:pointer, :string, :pointer], :int
    #int tool_modify(LDAP *ld, const char *dn, char *mods, int newentry, char **error_msg, char *delim);
    attach_function :tool_modify, [:pointer, :string, :string, :int, :pointer, :string], :int
    #int tool_rename(LDAP *ld, char *dn, char *new_rdn, char *new_parent, char **error_msg);
    attach_function :tool_rename, [:pointer, :string, :string, :string, :pointer], :int
    #void tool_unbind(LDAP *ld);
    attach_function :tool_unbind, [:pointer], :void
    #int ccache_init_krb5_tgt(char *principal_name, char *passwd, char *keytab_name, char **cache_name, char **error_msg);
    attach_function :ccache_init_krb5_tgt, [:string, :string, :string, :pointer, :pointer], :int
    #int ccache_krb5_clean(char *cache_name, char **error_msg);
    attach_function :ccache_krb5_clean, [:pointer, :pointer], :int
  end
end
