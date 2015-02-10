module Jekyll
  class URL
    def generate_url(template)
      @placeholders.inject(template) do |result, token|
        break result if result.index(':').nil?
        if token.last.nil?
          result.gsub(/\/:#{token.first}/, '')
        else
          result.gsub(/:#{token.first}/, self.class.escape_path(token.last))
        end
      end
    end
  end

  class Site
    def languages
      Octopress::Multilingual.languages
    end

    def posts_by_language
      Octopress::Multilingual.posts_by_language
    end

    def articles_by_language
      Octopress::Multilingual.articles_by_language
    end

    def linkposts_by_language
      Octopress::Multilingual.linkposts_by_language
    end
  end

  class Document
    def lang
      if data['lang']
        data['lang'].downcase
      end
    end
  end

  class Page
    alias :permalink_orig :permalink

    def lang
      if lang = data['lang']
        data['lang'] = site.config['lang'] if lang == 'default'
        data['lang'].downcase
      end
    end

    def translated
      data['translation_id'] && !translations.empty?
    end

    def translations
      if data['translation_id']
        @translations ||= Octopress::Multilingual.translated_pages[data['translation_id']].reject {|p| p == self }
      end
    end

    def permalink
      if lang && permalink = permalink_orig
        data['permalink'].sub!(/:lang/, lang)
        permalink.sub(/:lang/, lang)
      else
        permalink_orig
      end
    end
  end

  class Post
    alias :template_orig :template
    alias :url_placeholders_orig :url_placeholders

    def template
      template = template_orig

      if [:pretty, :none, :date, :ordinal].include? site.permalink_style
        template = File.join('/:lang', template)
      end

      template
    end

    def translated
      data['translation_id'] && !translations.empty?
    end

    def translations
      if data['translation_id']
        @translations ||= Octopress::Multilingual.translated_posts[data['translation_id']].reject {|p| p == self}
      end
    end

    def lang
      if data['lang']
        data['lang'].downcase
      end
    end

    def crosspost_languages
      data['lang_crosspost']
    end

    def url_placeholders
      url_placeholders_orig.merge({
        :lang => lang
      })
    end

    def next
      language = lang || site.config['lang']
      posts = Octopress::Multilingual.posts_by_language[language]

      pos = posts.index {|post| post.equal?(self) }
      if pos && pos < posts.length - 1
        posts[pos + 1]
      else
        nil
      end
    end

    def previous
      language = lang || site.config['lang']
      posts = Octopress::Multilingual.posts_by_language[language]

      pos = posts.index {|post| post.equal?(self) }
      if pos && pos > 0
        posts[pos - 1]
      else
        nil
      end
    end
  end
end

