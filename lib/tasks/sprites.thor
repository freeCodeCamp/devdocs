class SpritesCLI < Thor
  def self.to_s
    'Sprites'
  end

  def initialize(*args)
    require 'docs'
    require 'chunky_png'
    require 'fileutils'
    super
  end

  desc 'generate [--verbose]', 'Generate the documentation icon spritesheets'
  option :verbose, type: :boolean
  def generate
    items = get_items
    items_with_icons = items.select {|item| item[:has_icons]}
    items_without_icons = items.select {|item| !item[:has_icons]}
    icons_per_row = Math.sqrt(items_with_icons.length).ceil

    bg_color = get_sidebar_background

    items_with_icons.each_with_index do |item, index|
      if item[:has_icons]
        item[:row] = (index / icons_per_row).floor
        item[:col] = index - item[:row] * icons_per_row

        item[:icon_16] = get_icon(item[:path_16], 16)
        item[:icon_32] = get_icon(item[:path_32], 32)

        item[:dark_icon_fix] = needs_dark_icon_fix(item[:icon_32], bg_color)
      end
    end

    generate_spritesheet(16, items_with_icons, 'assets/images/sprites/docs.png') {|item| item[:icon_16]}
    generate_spritesheet(32, items_with_icons, 'assets/images/sprites/docs@2x.png') {|item| item[:icon_32]}

    # Add Mongoose's icon details to docs without custom icons
    template_item = items_with_icons.find {|item| item[:type] == 'mongoose'}
    items_without_icons.each do |item|
      item[:row] = template_item[:row]
      item[:col] = template_item[:col]
      item[:dark_icon_fix] = template_item[:dark_icon_fix]
    end

    save_manifest(items, icons_per_row, 'assets/images/sprites/docs.json')
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
    items.map do |item|
      item[:has_icons] = files.include?(item[:path_16]) && files.include?(item[:path_32])
      item
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
    regex = /\$sidebarBackground:\s+([^;]+);/
    ChunkyPNG::Color.parse(File.read(path)[regex, 1])
  end

  def needs_dark_icon_fix(icon, bg_color)
    # Determine whether the icon needs to be grayscaled if the user has enabled the dark theme
    # The logic comes from https://www.w3.org/TR/2008/REC-WCAG20-20081211/#visual-audio-contrast
    contrast = icon.pixels.map do |pixel|
      get_contrast(bg_color, pixel)
    end

    contrast.max < 7
  end

  def get_contrast(base, other)
    l1 = get_luminance(base) + 0.05
    l2 = get_luminance(other) + 0.05
    ratio = l1 / l2
    l2 > l1 ? 1 / ratio : ratio
  end

  def get_luminance(color)
    rgba = [
      ChunkyPNG::Color.r(color).to_f,
      ChunkyPNG::Color.g(color).to_f,
      ChunkyPNG::Color.b(color).to_f,
      ChunkyPNG::Color.a(color).to_f
    ]

    rgba.map! do |rgb|
      rgb /= 255
      rgb < 0.03928 ? rgb / 12.92 : ((rgb + 0.055) / 1.055) ** 2.4
    end

    0.2126 * rgba[0] + 0.7152 * rgba[1] + 0.0722 * rgba[2]
  end

  def generate_spritesheet(size, icons, output_path, &icon_to_img)
    logger.info("Generating spritesheet #{output_path} with icons of size #{size} x #{size}")

    icons_per_row = Math.sqrt(icons.length).ceil
    spritesheet = ChunkyPNG::Image.new(size * icons_per_row, size * icons_per_row)

    icons.each do |icon|
      img = icon_to_img.call(icon)

      # Calculate the base coordinates
      base_x = icon[:col] * size
      base_y = icon[:row] * size

      # Center the icon if it's not a perfect rectangle
      x = base_x + ((size - img.width) / 2).floor
      y = base_y + ((size - img.height) / 2).floor

      spritesheet.compose!(img, x, y)
    end

    FileUtils.mkdir_p(File.dirname(output_path))
    spritesheet.save(output_path)
  end

  def save_manifest(icons, icons_per_row, path)
    logger.info("Saving spritesheet details to #{path}")

    FileUtils.mkdir_p(File.dirname(path))

    # Only save the details that the scss file needs
    manifest_icons = icons.map do |icon|
      {
        :type => icon[:type],
        :row => icon[:row],
        :col => icon[:col],
        :dark_icon_fix => icon[:dark_icon_fix]
      }
    end

    manifest = {:icons_per_row => icons_per_row, :icons => manifest_icons}

    File.open(path, 'w') do |f|
      f.write(JSON.generate(manifest))
    end
  end

  def log_details(icons, icons_per_row)
    logger.debug("Amount of icons: #{icons.length}")
    logger.debug("Icons per row: #{icons_per_row}")

    max_type_length = icons.map { |icon| icon[:type].length }.max
    border = "+#{'-' * (max_type_length + 2)}+#{'-' * 5}+#{'-' * 8}+#{'-' * 15}+"
    logger.debug(border)
    logger.debug("| #{'Type'.ljust(max_type_length)} | Row | Column | Dark icon fix |")
    logger.debug(border)

    icons.each do |icon|
      logger.debug("| #{icon[:type].ljust(max_type_length)} | #{icon[:row].to_s.ljust(3)} | #{icon[:col].to_s.ljust(6)} | #{(icon[:dark_icon_fix] ? 'Yes' : 'No').ljust(13)} |")
    end

    logger.debug(border)
  end

  def logger
    @logger ||= Logger.new($stdout).tap do |logger|
      logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
      logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    end
  end
end
