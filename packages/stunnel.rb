require 'package'

class Stunnel < Package
  version '5.41'
  source_url 'https://www.stunnel.org/downloads/stunnel-5.41.tar.gz'
  source_sha1 '9aa8335e0f9571480b0d62b4b58d9d510447b732'

  depends_on 'openssl'

  def self.build
    system "./configure"
    system "make"
  end

  def self.install
    system "make", "DESTDIR=#{CREW_DEST_DIR}", "install"
  end
end
