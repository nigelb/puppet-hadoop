class hadoop::hosts
{
        define add_host($fqdn, $ip, $host_aliases)
        {
                host{$fqdn:
                        ip => $ip,
                        host_aliases => $host_aliases
                }
        }
        create_resources(hadoop::hosts::add_host, $::hosts)
}
