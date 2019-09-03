class SpritesCLI < Thor
  def self.to_s
    'Sprites'
  end

  def initialize(*args)
    require 'docs'
    require 'chunky_png'
    require 'fileutils'
    require 'image_optim'
    require 'terminal-table'
    super
  end

  desc 'generate [--remove-public-icons] [--disable-optimization] [--verbose]', 'Generate the documentation icon spritesheets'
  option :remove_public_icons, type: :boolean, desc: 'Remove public/icons after generating the spritesheets'
  option :disable_optimization, type: :boolean, desc: 'Disable optimizing the spritesheets with OptiPNG'
  option :verbose, type: :boolean
  def generate
    items = get_items
    items_with_icons = items.select {|item| item[:has_icons]}
    items_without_icons = items.select {|item| !item[:has_icons]}
    icons_per_row = Math.sqrt(items_with_icons.length).ceil

    bg_color = get_sidebar_background

    items_with_icons.each_with_index do |item, index|
      item[:row] = (index / icons_per_row).floor
      item[:col] = index - item[:row] * icons_per_row

      item[:icon_16] = get_icon(item[:path_16], 16)
      item[:icon_32] = get_icon(item[:path_32], 32)

      item[:dark_icon_fix] = needs_dark_icon_fix(item[:icon_32], bg_color)
    end

    return unless items_with_icons.length > 0

    log_details(items_with_icons, icons_per_row) if options[:verbose]

    generate_spritesheet(16, items_with_icons) {|item| item[:icon_16]}
    generate_spritesheet(32, items_with_icons) {|item| item[:icon_32]}

    unless options[:disable_optimization]
      optimize_spritesheet(get_output_path(16))
      optimize_spritesheet(get_output_path(32))
    end

    # Add Mongoose's icon details to docs without custom icons
    default_item = items_with_icons.find {|item| item[:type] == 'mongoose'}
    items_without_icons.each do |item|
      item[:row] = default_item[:row]
      item[:col] = default_item[:col]
      item[:dark_icon_fix] = default_item[:dark_icon_fix]
    end

    save_manifest(items, icons_per_row, 'assets/images/sprites/docs.json')

    if options[:remove_public_icons]
      logger.info('Removing public/icons')
      FileUtils.rm_rf('public/icons')
    end
  end

  private

  def get_items
    items = Docs.all.map do |doc|
      base_path = "public/icons/docs/#{doc.slug}"
      {
        :type => doc.slug,
        :path_16 => "#{base_path}/16.png",
        :path_32 => "#{base_path}/16@2x.png"
      }
    end

    # Checking paths against an array of possible paths is faster than 200+ File.exist? calls
    files = Dir.glob('public/icons/docs/**/*.png')

    items.each do |item|
      item[:has_icons] = files.include?(item[:path_16]) && files.include?(item[:path_32])
    end
  end

  def get_icon(path, max_size)
    icon = ChunkyPNG::Image.from_file(path)

    # Check if the icon is too big
    # If it is, resize the image without changing the aspect ratio
    if icon.width > max_size || icon.height > max_size
      ratio = icon.width.to_f / icon.height
      new_width = (icon.width >= icon.height ? max_size : max_size * ratio).floor
      new_height = (icon.width >= icon.height ? max_size / ratio : max_size).floor

      logger.warn("Icon #{path} is too big: max size is #{max_size} x #{max_size}, icon is #{icon.width} x #{icon.height}, resizing to #{new_width} x #{new_height}")

      icon.resample_nearest_neighbor!(new_width, new_height)
    end

    icon
  end

  def get_sidebar_background
    # This is a hacky way to get the background color of the sidebar
    # Unfortunately, it's not possible to get the value of a SCSS variable from a Thor task
    # Because hard-coding the value is even worse, we extract it using some regex
    path = 'assets/stylesheets/global/_variables-dark.scss'
    regex = /--sidebarBackground:\s+([^;]+);/
    ChunkyPNG::Color.parse(File.read(path)[regex, 1])
  end

  def needs_dark_icon_fix(icon, bg_color)
    # Determine whether the icon needs to be grayscaled if the user has enabled the dark theme
    # The logic is roughly based on https://www.w3.org/TR/2008/REC-WCAG20-20081211/#visual-audio-contrast
    contrast = icon.pixels.select {|pixel| ChunkyPNG::Color.a(pixel) > 0}.map do |pixel|
      get_contrast(bg_color, pixel)
    end

    avg = contrast.reduce(:+) / contrast.size.to_f
    avg < 2.5
  end

  def get_contrast(base, other)
    # Calculating the contrast ratio as described in the WCAG 2.0:
    # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
    l1 = get_luminance(base) + 0.05
    l2 = get_luminance(other) + 0.05
    ratio = l1 / l2
    l2 > l1 ? 1 / ratio : ratio
  end

  def get_luminance(color)
    rgb = [
      ChunkyPNG::Color.r(color).to_f,
      ChunkyPNG::Color.g(color).to_f,
      ChunkyPNG::Color.b(color).to_f
    ]

    # Calculating the relative luminance as described in the WCAG 2.0:
    # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef

    rgb.map! do |value|
      value /= 255
      value <= 0.03928 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4
    end

    0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]
  end

  def generate_spritesheet(size, items_with_icons, &item_to_icon)
    output_path = get_output_path(size)

    logger.info("Generating spritesheet to #{output_path} with icons of size #{size} x #{size}")

    icons_per_row = Math.sqrt(items_with_icons.length).ceil
    spritesheet = ChunkyPNG::Image.new(size * icons_per_row, size * icons_per_row)

    items_with_icons.each do |item|
      icon = item_to_icon.call(item)

      # Calculate the base coordinates
      base_x = item[:col] * size
      base_y = item[:row] * size

      # Center the icon if it's not a perfect rectangle
      x = base_x + ((size - icon.width) / 2).floor
      y = base_y + ((size - icon.height) / 2).floor

      spritesheet.compose!(icon, x, y)
    end

    FileUtils.mkdir_p(File.dirname(output_path))
    spritesheet.save(output_path)
  end

  def optimize_spritesheet(path)
    logger.info("Optimizing spritesheet at #{path}")
    image_optim.optimize_image!(path)
  end

  def save_manifest(items, icons_per_row, path)
    logger.info("Saving spritesheet details to #{path}")

    FileUtils.mkdir_p(File.dirname(path))

    # Only save the details that the scss file needs
    manifest_items = items.map do |item|
      {
        :type => item[:type],
        :row => item[:row],
        :col => item[:col],
        :dark_icon_fix => item[:dark_icon_fix]
      }
    end

    manifest = {:icons_per_row => icons_per_row, :items => manifest_items}

    File.open(path, 'w') do |f|
      f.write(JSON.generate(manifest))
    end
  end

  def log_details(items_with_icons, icons_per_row)
    title = "#{items_with_icons.length} items with icons (#{icons_per_row} per row)"
    headings = ['Type', 'Row', 'Column', "Dark icon fix (#{items_with_icons.count {|item| item[:dark_icon_fix]}})"]
    rows = items_with_icons.map {|item| [item[:type], item[:row], item[:col], item[:dark_icon_fix] ? 'Yes' : 'No']}

    table = Terminal::Table.new :title => title, :headings => headings, :rows => rows
    puts table
  end

  def get_output_path(size)
    "assets/images/sprites/docs#{size == 32 ? '@2x' : ''}.png"
  end

  def image_optim
    @image_optim ||= ImageOptim.new(
      :config_paths => [],
      :advpng => false,
      :gifsicle => false,
      :jhead => false,
      :jpegoptim => false,
      :jpegrecompress => false,
      :jpegtran => false,
      :pngcrush => false,
      :pngout => false,
      :pngquant => false,
      :svgo => false,
      :optipng => {
        :level => 7,
      },
    )
  end

  def logger
    @logger ||= Logger.new($stdout).tap do |logger|
      logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
      logger.formatter = proc {|severity, datetime, progname, msg| "#{msg}\n"}
    end
  end
end
