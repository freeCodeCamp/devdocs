require 'find'
require 'fileutils'
require 'nokogiri'
require 'json'
require 'downloader'

class DevHelp
  SKIP_ASSETS = %{.json .js .gz}
  DEVHELP_NS = 'http://www.devhelp.net/book'

  def initialize(options)
    @options = options
  end

  def book_options(doc)
    {
      xmlns: DEVHELP_NS,
      title: doc.name,
      name: "#{doc.slug}-#{doc.version}",
      version: 2,
      author: '',
      language: doc.language,
      link: 'index.html'
    }
  end

  def normalize_url(link)
    link.gsub(/^([^.]+?)(?=$|#)/, '\1.html\2')
  end

  def build_devhelp(doc, structure)
    builder do |xml|
      xml.book book_options(doc) do
        xml.doc.create_internal_subset('book', '-//W3C//DTD HTML 4.01 Transitional//EN', '')
        xml.chapters do
          structure[:terms].each do |term, link|
            xml.sub name: term, link: normalize_url(link)
          end
        end
      end
    end.to_xml
  end

  def for_docs(*docs)
    docs.flatten.each(&method(:for_doc))
  end

  def cp_r(src, dst)
    t = File.dirname(dst)
    FileUtils.mkdir_p(t) unless File.directory?(t)
    FileUtils.cp_r(src, dst)
  end

  def prepare_assets(src, dst)
    cp_r(src, dst)
    Find.find(dst).select do |file|
      ext = File.extname(file).downcase
      File.unlink(file) if File.file?(file) && SKIP_ASSETS.include?(ext)
      ext == '.css'
    end
  end

  def prepare_js(js, dst)
    js.map do |file|
      npath = File.join(dst, File.basename(file))
      FileUtils.cp(file, npath)
      npath
    end
  end

  def make_devhelp_file(doc, src, dst, unlink = false)
    structure = parse_index(src)
    File.write(dst, build_devhelp(doc, structure))
    File.unlink(src)
    structure
  end

  def downloader
    @downloader ||= Downloader.new
  end

  def document_structure(doc, type)
    doc.internal_subset.remove
    doc.create_internal_subset('html', nil, nil)

    unless doc.at_css('head')
      title = Nokogiri::XML::Node.new 'head', doc
      doc.root.children.first.add_previous_sibling title
    end

    body = doc.at_css('body')
    content = body.children.remove

    body.add_child <<-EOF
      <section class="_container _devhelp">
        <div class="_content _#{type}">
          #{content}
        </div>
      </section>
    EOF
  end

  def set_title(doc, text = nil)
    unless text
      h1 = doc.at_css('h1, h2, h3, h4, h5')
      return unless h1
      text = h1.text.strip
    end

    title = doc.at_css('title')
    unless title
      title = Nokogiri::XML::Node.new 'title', doc
      doc.at_css('head').add_child(title)
    end

    title.content = text
  end

  def inject_assets(doc, path, css, js, skip)
    head = doc.at_css('head')
    level = ['..'] * path[skip].count(File::SEPARATOR)

    css.each do |asset|
      link = Nokogiri::XML::Node.new 'link', doc
      link['rel'] = 'stylesheet'
      link['media'] = 'all'
      link['charset'] = 'UTF-8'
      link['href'] = File.join(level + [asset[skip]])
      head.add_child(link)
    end

    body = doc.at_css('body')
    js.each do |asset|
      script = Nokogiri::XML::Node.new 'script', doc
      script['type'] = 'text/javascript'
      script['charset'] = 'UTF-8'
      script['src'] = File.join(level + [asset[skip]])
      body.add_child(script)
    end
  end

  def src_for(doc)
    src_path = File.join(@options[:base_path], doc.path)

    unless File.exists?(src_path)
      puts %(ERROR: can't find "#{doc.name}" documentation files. Please download/scrape it first.)
      return nil
    end
   
    src_path
  end

  def dst_for(doc)
    dst_path = File.join(@options[:devhelp_path], doc.path)

    if File.exists?(dst_path)
      unless @options[:force]
        puts %(ERROR: #{doc.name} was already converted. Use --force to overwrite.)
        return nil
      end

      FileUtils.rm_rf(dst_path)
    end
   
    dst_path
  end

  def for_doc(doc)
    src_path = src_for(doc) || return
    dst_path = dst_for(doc) || return

    cp_r(src_path, dst_path)

    css = prepare_assets(@options[:asset_path], File.join(dst_path, 'assets'))
    js = prepare_js(@options[:js], File.join(dst_path, 'assets'))

    titles = make_devhelp_file(doc,
                               File.join(dst_path, @options[:index]),
                               File.join(dst_path, "#{doc.slug}.devhelp2"),
                               true)

    skip = (dst_path.length + 1) .. -1

    downloader.processor do |file, parser|
      document_structure(parser, doc.type)
      set_title(parser, titles[:files][file[skip]])
      inject_assets(parser, file, css, js, skip)
    end

    Find.find(dst_path).
      select(&method(:is_document?)).
      each {|d| downloader.process_page(nil, d)}

    downloader.run
  end

  def is_document?(p)
    !File.basename(p).starts_with?('.') && p.ends_with?('.html') && File.file?(p)
  end

  def builder(&block)
    Nokogiri::XML::Builder.new(encoding: 'UTF-8', &block)
  end

  def parse_index(path)
    structure = {terms: {}, files: {}}

    JSON.load(open(path))['entries'].each do |e, o|
      structure[:terms][e['name']] = e['path']

      unless e['path'].include?('#')
       structure[:files][e['path']] = e['name']
      end
    end

    structure
  end
end
