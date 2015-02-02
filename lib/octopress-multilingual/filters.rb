module Octopress
  module Multilingual
    module Filters
      def language_name(input)
        if input
          Octopress::Multilingual.language_names(input.strip.downcase) || input
        end
      end
    end
  end
end

Liquid::Template.register_filter(Octopress::Multilingual::Filters)
