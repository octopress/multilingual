module Octopress
  module Multilingual
    Jekyll::Hooks.register :site, :post_read, priority: :high do |site|
      Octopress::Multilingual.site = site
      site.config['languages'] = Octopress::Multilingual.languages
    end

    Jekyll::Hooks.register :site, :pre_render, priority: :high do |site, payload|
      [site.pages, site.posts].flatten.select(&:translated).each do |item|
        # Access array of translated items via (post/page).translations
        item.data.merge!({
          'translations' => item.translations,
          'translated' => item.translated
        })
      end

      Octopress::Multilingual.site_payload payload
    end

    Jekyll::Hooks.register [:page, :post], :post_init, priority: :high do |item|
      if item.lang == 'default'
        item.data['lang'] = item.site.config['lang']
      end
    end

    Jekyll::Hooks.register :document, :pre_render, priority: :high do |item|
      if item.lang == 'default'
        item.data['lang'] = item.site.config['lang']
      end
    end

    Jekyll::Hooks.register [:page, :post, :document], :pre_render, priority: :high do |item, payload|
      Octopress::Multilingual.page_payload(item.lang, payload)
    end
  end
end
