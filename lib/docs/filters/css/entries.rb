module Docs
  class Css
    class EntriesFilter < Docs::EntriesFilter
      DATA_TYPE_SLUGS = %w(angle basic-shape color_value counter frequency
        gradient image integer length number percentage position_value ratio
        resolution shape string time timing-function uri user-ident)

      FUNCTION_SLUGS = %w(attr calc cross-fade cubic-bezier cycle element
        linear-gradient radial-gradient repeating-linear-gradient
        repeating-radial-gradient var)

      PSEUDO_ELEMENT_SLUGS = %w(::after ::before ::first-letter ::first-line
        ::selection)

      VALUE_SLUGS = %w(auto inherit initial none normal unset)

      ADDITIONAL_ENTRIES = {
        'shape' => [
          %w(rect() Syntax Functions) ],
        'uri' => [
          %w(url() The_url()_functional_notation Functions) ],
        'timing-function' => [
          %w(cubic-bezier() The_cubic-bezier()_class_of_timing-functions Functions),
          %w(steps() The_steps()_class_of_timing-functions Functions),
          %w(linear linear Values),
          %w(ease ease Values),
          %w(ease-in ease-in Values),
          %w(ease-in-out ease-in-out Values),
          %w(ease-out ease-out Values),
          %w(step-start step-start Values),
          %w(step-end step-end Values) ],
        'color_value' => [
          %w(transparent transparent_keyword Values),
          %w(currentColor currentColor_keyword Values),
          %w(rgb() rgb() Functions),
          %w(hsl() hsl() Functions),
          %w(rgba() rgba() Functions),
          %w(hsla() hsla() Functions) ],
        'transform-function' => [
          %w(matrix() matrix() Functions),
          %w(matrix3d() matrix3d() Functions),
          %w(rotate() rotate() Functions),
          %w(rotate3d() rotate3d() Functions),
          %w(rotateX() rotateX() Functions),
          %w(rotateY() rotateY() Functions),
          %w(rotateZ() rotateZ() Functions),
          %w(scale() scale() Functions),
          %w(scale3d() scale3d() Functions),
          %w(scaleX() scaleX() Functions),
          %w(scaleY() scaleY() Functions),
          %w(scaleZ() scaleZ() Functions),
          %w(skew() skew() Functions),
          %w(skewX() skewX() Functions),
          %w(skewY() skewY() Functions),
          %w(translate() translate() Functions),
          %w(translate3d() translate3d() Functions),
          %w(translateX() translateX() Functions),
          %w(translateY() translateY() Functions),
          %w(translateZ() translate(Z) Functions) ]}

      def get_name
        case type
        when 'Data Types' then "<#{super.remove ' value'}>"
        when 'Functions'  then "#{super}()"
        else super
        end
      end

      def get_type
        if slug.end_with? 'selectors'
          'Selectors'
        elsif slug.start_with? ':'
          PSEUDO_ELEMENT_SLUGS.include?(slug) ? 'Pseudo-elements' : 'Pseudo-classes'
        elsif slug.start_with? '@'
          'At-rules'
        elsif DATA_TYPE_SLUGS.include?(slug)
          'Data Types'
        elsif FUNCTION_SLUGS.include?(slug)
          'Functions'
        elsif VALUE_SLUGS.include?(slug)
          'Values'
        else
          'Properties'
        end
      end

      def additional_entries
        ADDITIONAL_ENTRIES[slug] || []
      end
    end
  end
end
