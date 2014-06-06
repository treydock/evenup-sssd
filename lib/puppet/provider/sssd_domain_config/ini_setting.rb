Puppet::Type.type(:sssd_domain_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:sssd_config).provider(:ini_setting)
) do

  def section
    "domain/" + resource[:name].split('/', 2).first
  end
end
