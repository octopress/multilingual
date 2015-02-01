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
      if data['lang']
        data['lang'].downcase
      end
    end

    def permalink
      if permalink = permalink_orig
        data['permalink'].sub!(/:lang/, lang)
        permalink.sub(/:lang/, lang)
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

    def lang
      if data['lang']
        if data['lang'].downcase == 'all'
          @language_crosspost = true
          data['lang'] = site.config['lang']
        end
        data['lang'].downcase
      end
    end

    def language_crosspost
      @language_crosspost if lang
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

