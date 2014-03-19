module Puppet::Parser::Functions
  newfunction(:x509_to_text, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|


    ENDHEREDOC

    require 'openssl'

    raise Puppet::ParseError, ("x509_to_text(): Wrong number of arguments (#{args.length}; must be = 1)") unless args.length == 1

    file = args[0]

    begin
      pem = File::read(file)
    rescue Errno::ENOENT
      raise Puppet::ParseError, ("x509_to_text(): File not found (#{file})")
    end

    cert = OpenSSL::X509::Certificate.new(pem)
    result = "#{cert.to_text}#{cert.to_pem}"

    return result
  end
end
