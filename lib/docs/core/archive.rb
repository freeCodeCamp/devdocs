require 'open-uri'
require 'securerandom'
require 'tmpdir'

module Docs
  # Downloads and unpacks the archives holding the documentation files, the
  # latter by shelling out to bsdtar. bsdtar reads zip archives as well as
  # tarballs and extracts a directory out of either, which is why it's required
  # over tar and unzip. (This used to be the job of the unix_utils gem, which
  # wraps those commands but hasn't seen a release since 2012 and doesn't know
  # about xz.)
  module Archive
    extend self

    # Downloads a url into a temporary file and returns its path. The name of
    # the file is preserved, as bsdtar relies on its extension.
    def download(url)
      path = File.join(Dir.tmpdir, "devdocs-#{SecureRandom.hex(4)}-#{filename(url)}")
      URI.open(url) { |response| IO.copy_stream(response, path) }
      path
    rescue OpenURI::HTTPError => error
      FileUtils.rm_f(path) if path
      raise SetupError, %(Failed to download "#{url}": #{error.message})
    rescue
      FileUtils.rm_f(path) if path
      raise
    end

    # Unpacks the contents of an archive into destination, replacing it. Pass a
    # directory inside the archive to unpack that one alone, without its
    # parents. Nothing is left behind when the archive can't be unpacked.
    def unpack(archive, destination, directory: nil)
      FileUtils.rm_rf(destination)
      FileUtils.mkpath(destination)

      argv = ['bsdtar', '-xf', archive, '-C', destination]
      # The components of the directory are stripped from every member that's
      # extracted, so that its contents end up at the root of destination.
      argv.push("--strip-components=#{directory.count('/') + 1}", directory) if directory
      run(*argv)
    rescue
      FileUtils.rm_rf(destination)
      raise
    end

    # Packs the contents of a directory into a gzipped tarball.
    def pack(directory, archive)
      run 'bsdtar', '-czf', archive, '-C', directory, '.'
    end

    private

    def filename(url)
      File.basename(URL.parse(url).path.to_s).presence || 'archive'
    end

    def run(*argv)
      return if system(*argv)
      # 127 is what the failure to run the command itself looks like.
      raise SetupError, %(#{argv.first} is required to unpack the documentation archives.) if $?&.exitstatus == 127
      raise SetupError, %(Command failed: #{argv.join(' ')})
    end
  end
end
