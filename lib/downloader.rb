require 'typhoeus'
require 'nokogiri'
require 'delegate'
require 'fileutils'
require 'cgi'

class Downloader < SimpleDelegator
  include Typhoeus

  MAX_QUEUE_SIZE = 20

  def initialize(*args)
    super(Hydra.new(*args))
  end

  def processor(&block)
    @processor = block
  end

  def queue_size
    queued_requests.size
  end

  def file(src, dst, &block)
    file = nil

    request = Request.new(src)

    request.on_headers do |response|
      if response.response_code == 200
        dname = File.dirname(dst)
        FileUtils.mkdir_p(dname) unless File.directory?(dname)
        file = open(dst, 'wb')
      else
        failed(src, dst, response)
      end
    end

    request.on_body do |chunk|
      file.write(chunk) if file
    end
    
    request.on_complete do |response|
      if file
        file.close
        block.call(dst) if block
      end
    end

    queue request
    dst
  end

  def queue(*args, &block)
    run while queue_size > MAX_QUEUE_SIZE
    __getobj__(*args, &block)
  end

  def page(src, target)
    file(src, target) { process_page(src, target) }
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

    puts rfile

    loop do
      path = File.join(dir, tfile)
      break path unless File.exists?(path)
      tfile = "#{prefix}_#{rfile}"
      prefix += 1
    end
  end

  def failed(src, dst, response)
    puts "#{src} -> #{dst} failed: #{response.status_message}"
  end
end
