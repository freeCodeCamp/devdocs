require 'nokogiri'
require 'thread'
require 'fileutils'
require 'monitor'
require 'cgi'

# Typhoeus has odd behavior either on my platform
# or at all. Hence rolling out own parallel downloader.

# Ruby 2.1.0 has broken Thread::SizedQueue
# https://bugs.ruby-lang.org/issues/9342
class SizedQueue
  attr_accessor :max

  def initialize(max)
     @max = max

     @queue = []
     @queue.extend(MonitorMixin)
     @qe = @queue.new_cond
     @qd = @queue.new_cond
  end

  def size
    @queue.synchronize do
      @queue.size
    end
  end

  def enqueue(what)
    @queue.synchronize do
      @qd.wait_while { @queue.size >= @max }
      @queue.push what
      @qe.signal
    end
  end

  def dequeue
    @queue.synchronize do
      @qe.wait_while { @queue.empty? }
      ret = @queue.pop
      @qd.signal
      ret
    end
  end

  alias :<<      :enqueue
  alias :push    :enqueue
  alias :unshift :enqueue

  alias :>>      :dequeue
  alias :pop     :dequeue
  alias :shift   :dequeue
end

class Downloader
  def initialize(threads = 10, max = 10)
    @counter = 0
    @req = SizedQueue.new(max)
    @callbacks = Thread::Queue.new
    @threads = []

    @threads << Thread.new(&method(:runner))

    block = method(:downloader)
    threads.times do
      @threads << Thread.new(&block)
    end
  end

  def downloader
    while r = @req.pop
      begin
        open(r[0]) do |f|
          dname = File.dirname(r[1])
          FileUtils.mkdir_p(dname) unless File.directory?(dname)
          File.write(r[1], f.read)
          @callbacks << r[1..-1] if r[2]
        end
      rescue SocketError, OpenURI::HTTPError, Errno::EACCESS, Errno::EEXISTS => e
        puts "#{r[1]} failed to download: #{e.message}"
      end
    end
  end

  def runner
    while t = @callbacks.pop
      t[1].call(t[0])
    end
  end

  def processor(&block)
    @processor = block
  end

  def file(src, dst, &block)
    @req << [src, dst, block]
    dst
  end

  def wait
    @callbacks << nil
    (@threads.size - 1).times { @req << nil }
    @threads.each(&:join)
  end

  def page(src, target)
    file(src, target) { process_page(src, target) }
  end

  def guess_filename(base_dir, href)
    tpath = File.join(base_dir, href)

    [
      [tpath                    , href                   ],
      ["#{tpath}.html"          , "#{href}.html"         ],
      ["#{tpath.downcase}"      , "#{href.downcase}"     ],
      ["#{tpath.downcase}.html" , "#{href.downcase}.html"]
    ].each {|(x, y)| return y if File.exists?(x)}

    href
  end

  def process_page(src, path)
    doc = Nokogiri::HTML.parse(File.read(path), 'UTF-8')
    rdir = path.gsub(%r{\.[^./]*$}, '') + '_files'
    skip = dirname_range(path)

    doc.css('iframe[src], img[src], script[src], link[href][rel="stylesheet"], link[href][rel="shortcut icon"]').each do |elem|
      uri = url_join(src, elem['src'] || elem['href'])

      case elem.name
      when 'iframe'
        elem['src']  = page(uri, resource_path_for(rdir, uri, 'html'))[skip]
      when 'link'
        elem['href'] = file(uri, resource_path_for(rdir, uri, 'css')) do |f|
          process_stylesheet_file(uri, f) if elem['rel'] == 'stylesheet'
        end[skip]
      when 'script'
        elem['src']  = file(uri, resource_path_for(rdir, uri, 'js'))[skip]
      when 'img'
        elem['src']  = file(uri, resource_path_for(rdir, uri, 'png'))[skip]
      end
    end

    base_dir = File.dirname(path)
    doc.css('a[href]').each do |a|
      href = a['href']
      next if href =~ %r{^(?:[^:]+:|[#?]|$)}
      href = CGI.unescape(href)
      a['href'] = guess_filename(base_dir, href)
    end

    doc.css('style').each do |style|
      style.content = process_stylesheet(src, style.content, rdir)
    end

    @processor.call(path, doc) if @processor

    File.write(path, doc.to_html)
  end

  protected

  def dirname_range(path, dirname = false)
    path = File.dirname(path) unless dirname
    l = path.length
    l += 1 if l > 0
    l..-1
  end

  def process_stylesheet_file(src, fname)
    File.write(fname, process_stylesheet(src, File.read(fname), File.dirname(fname)))
  end

  def process_stylesheet(src, style, dir)
    skip = dirname_range(dir, true)

    style = style.gsub(/@import\s*(?:url\s*)?(?:\()?(?:\s*)["']?([^'"\s\)]*)["']?\)?([\w\s\,^\]\(\)]*)\)?[;\n]?/) do
      uri = url_join(src, $1)
      fname = resource_path_for(dir, uri, 'css')
      file(uri, fname) { process_stylesheet_file(uri, fname) }
      %{@import url("#{fname[skip]}") #$2;\n}
    end

    style = style.gsub(/(?!@import )url\s*\(["']?(.+?)["']?\)/) do
      uri = url_join(src, $1)
      fname = resource_path_for(dir, uri, 'png')
      file(uri, fname)
      %{url("#{fname[skip]}")}
    end

    style
  end

  def url_join(base, new)
    if base && new
      URI.join(base, new).to_s
    else
      base || new
    end
  end

  def resource_path_for(dir, resource, ext = nil)
    rfile = CGI.unescape(resource.gsub(%r{.*/|[#?].*}, ''))

    if rfile.empty?
      rfile = "downloaded#{'%04d' % @counter}"
      @counter += 1
    end

    rfile << ".#{ext}" if ext && File.extname(rfile).empty?

    prefix = 1
    tfile = rfile

    loop do
      path = File.join(dir, tfile)
      break path unless File.exists?(path)
      tfile = "#{prefix}_#{rfile}"
      prefix += 1
    end
  end
end
