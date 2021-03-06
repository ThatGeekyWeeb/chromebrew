require 'package'

class Ccache < Package
  description 'Compiler cache that speeds up recompilation by caching previous compilations'
  homepage 'https://ccache.samba.org/'
  version '4.1'
  license 'GPL-3 and LGPL-3'
  compatibility 'all'
  source_url 'https://github.com/ccache/ccache/releases/download/v4.1/ccache-4.1.tar.xz'
  source_sha256 '5fdc804056632d722a1182e15386696f0ea6c59cb4ab4d65a54f0b269ae86f99'

  binary_url ({
     aarch64: 'https://dl.bintray.com/chromebrew/chromebrew/ccache-4.1-chromeos-armv7l.tar.xz',
      armv7l: 'https://dl.bintray.com/chromebrew/chromebrew/ccache-4.1-chromeos-armv7l.tar.xz',
        i686: 'https://dl.bintray.com/chromebrew/chromebrew/ccache-4.1-chromeos-i686.tar.xz',
      x86_64: 'https://dl.bintray.com/chromebrew/chromebrew/ccache-4.1-chromeos-x86_64.tar.xz',
  })
  binary_sha256 ({
     aarch64: '6ac906edece6c4ec603f9b5816f67a8863352f43f6a9814cc0db53da351e2a79',
      armv7l: '6ac906edece6c4ec603f9b5816f67a8863352f43f6a9814cc0db53da351e2a79',
        i686: '3e76036380a5f5c18856788c82a2c9a56cb1c5321b9ae8ed78a18d164fe4b80f',
      x86_64: '5c4c9e014f23977f2f031eb9f9b367881a20fa8effeac9e38289cd723aa11e62',
  })

  depends_on 'xdg_base'
  depends_on 'asciidoc' => :build

  def self.build
    ENV['CFLAGS'] = '-flto'
    ENV['CXXFLAGS'] = '-flto'
    Dir.mkdir 'build'
    Dir.chdir 'build' do
      system "cmake -G Ninja \
      #{CREW_CMAKE_OPTIONS} \
      -DCMAKE_INSTALL_SYSCONFDIR=#{CREW_PREFIX}/etc \
      -DZSTD_FROM_INTERNET=ON \
      .."
      system "ninja"
    end
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} ninja -C build install"
    Dir.chdir 'build' do
      FileUtils.mkdir_p "#{CREW_DEST_LIB_PREFIX}/ccache/bin"
      system "for _prog in gcc g++ c++; do
        ln -s #{CREW_PREFIX}/bin/ccache #{CREW_DEST_LIB_PREFIX}/ccache/bin/$_prog
        ln -s #{CREW_PREFIX}/bin/ccache #{CREW_DEST_LIB_PREFIX}/ccache/bin/${CHOST}-$_prog
      done
      for _prog in cc clang clang++; do
        ln -s #{CREW_PREFIX}/bin/ccache #{CREW_DEST_LIB_PREFIX}/ccache/bin/$_prog
      done"
    end
  end

  def self.postinstall
    system "ccache --set-config=sloppiness=file_macro,locale,time_macros"
    puts "To compile using ccache you need to add the ccache bin folder to your path".lightblue
    puts "e.g.  put this in your ~/bashrc:".lightblue
    puts "export PATH=#{CREW_LIB_PREFIX}/ccache/bin::#{CREW_PREFIX}/bin:/usr/bin:/bin".lightblue
    # To modify a package use the following:
    # ENV['PATH'] = "#{CREW_LIB_PREFIX}/ccache/bin:#{CREW_PREFIX}/bin:/usr/bin:/bin"
  end
end
