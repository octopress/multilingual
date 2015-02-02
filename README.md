# Octopress Multilingual

Add multiple language features to your Jekyll site. This plugin makes it easy to:

- Add language-specific post indexes, archives, and RSS feeds.
- Link between translated posts and pages.
- Use language in your permalinks. 
- Cross-post between languages.

[![Build Status](http://img.shields.io/travis/octopress/multilingual.svg)](https://travis-ci.org/octopress/multilingual)
[![Gem Version](http://img.shields.io/gem/v/octopress-multilingual.svg)](https://rubygems.org/gems/octopress-multilingual)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://octopress.mit-license.org)

## Installation

If you're using bundler add this gem to your site's Gemfile in the `:jekyll_plugins` group:

    group :jekyll_plugins do
      gem 'octopress-multilingual'
    end

Then install the gem with Bundler

    $ bundle

To install manually without bundler:

    $ gem install octopress-multilingual

Then add the gem to your Jekyll configuration.

    gems:
      - octopress-multilingual


## An important note

**There is no Jekyll standard for multilingual sites** and many plugins will not work properly with this setup. Octopress and it's
plugins are being designed to support multilingual features, but without a standard, some use-cases may be overlooked. If you have a
problem with an Octopress plugin supporting your multilingual site, please file an issue and we'll do our best to address it.

Note: First-party Octopress plugins are designed to support multilingual sites but other plugins may not work how you'd expect on multilingual sites. Modifying plugins is beyond the scope of this guide.

Also, if you are using flags to represent languages on your site, you might like to read, [Why flags do not represent language](http://flagsarenotlanguages.com/blog/why-flags-do-not-represent-language/).

## Setup

When adding this plugin to your site, you will need to:

1. Configure your site's main language, e.g. `lang: en`.
2. Add a language to the YAML front-matter of your posts, e.g. `lang: de`.
3. Add new RSS feeds and post indexes for secondary languages.

First, be sure to configure your Jekyll site's main language. An site written primarily in English would add this to its Jekyll configuration:

```yaml
lang: en
```

Here we are setting the default language to English. Posts without a defined language will be treated as English posts.
For a list of standard language codes, refer to [ISO 639-1](http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes). You can also use
the [language]-[region] method of setting your site's language, like `en-us` for American English or `de-at` for Austrian German.

### Setting a language for pages or posts

Specify a page or post's language in the YAML front matter.

```yaml
title: "Ein nachdenklicher Beitrag"
lang: de
```

With Octopress, you can do this automatically from the command line when creating posts, drafts, or pages.

```
$ octopress new post "Some title" --lang en
$ octopress new draft "Some title" --lang en
$ octopress new page de/index.html --lang de
```

This command will set the language (in the YAML front-matter) and posts will be created in `_posts/[lang]/[post-file]`.

## Indexes, RSS feeds and Archives.

If you are writing English and German posts, you'll want an English-only and a German-only post index. To do that, just set the
language in the YAML front-matter of your post-index. 

For example, this will loop through only German posts:

```
---
lang: de
---
{% for post in site.posts %} ... {% endfor %}
```

And this will loop through only English posts:

```
---
lang: en
---
{% for post in site.posts %} ... {% endfor %}
```

If your default post index is at `/index.html` you should create additional indexes for each secondary language. If you also write in German, you can create a posts index at `/de/index.html`. This approach will work for post archives and RSS feeds, though if you are using [octopress-feeds](https://github.com/octopress/feeds), RSS feeds for each language will be generated automatically.

How does it work? First this plugin groups all of your posts by language. Then at build time, any page with a language defined will
have its posts filtered to display only matching languages. If your site uses [octopress-linkblog](https://github.com/octopress/linkblog) to publish link-posts, your `site.articles` and `site.linkposts` will be filtered as well.

## Link between translated posts or pages

URLs can change and manually linking to translated posts or pages isn't the best idea. This plugin helps you link posts together using
a shared translation ID. With [octopress](https://github.com/octopress/octopress), you'll be able to automatically add translation IDs to pages and posts. Then you can reference the array of translations with `post.tranlsations` or `page.translations`. Here's the syntax:

```
$ octopress translate path [path path...]
```

This will create a unique key and automatically write it to the YAML front-matter each of the pages or posts you pass in. Here's an
example:

```
$ octopress translate _posts/2015-02-02-english-post.md _posts/2015-02-02-deutsch-post.md
```

Here is what the YAML front-matter looks like now for these posts:

```
---
title: This post is written in English
lang: en
translation_id: 129dlkj19dj19j1ljd1iu1optva
---
```

```
---
title: Dies wird in deutscher Sprache
lang: de
translation_id: 129dlkj19dj19j1ljd1iu1optva
---
```

Then in your templates you can loop through the translations like this:

```
{% if page.translated %}
  Translations: {% for t in page.translations %}
    <a href="{{ t.url }}">{{ t.lang }}</a>
  {% endfor %}
{% endif %}
```

## Reference posts by language

All posts are grouped by language and can be accessed directly with `site.posts_by_language`. For example:

```
{% for post in site.posts_by_language.de %}  # German posts
{% for post in site.posts_by_language.en %}  # English posts
```

If you have [octopress-linkblog](https://github.com/octopress/linkblog) installed, you can access groups of link-posts and articles too.

```
{% for post in site.linkposts_by_language.de %}  # German linkposts
{% for post in site.articles_by_language.de %}   # German articles
```

### Cross-posting languages

If you would like to write a post which shows up in indexes and feeds for every language, set `lang_crosspost: true` in your post's YAML front-matter.

```
title: "Ein nachdenklicher Beitrag"
lang: de
lang_crosspost: true
```

This post will show up with every language. However, it will be treated exactly like a post written in German
and will have one canonical URL.

### Language in permalinks

This plugin does not use categories to add language to URLs. Instead it adds the `:lang` key to Jekyll's permalink template.
Any post **with a defined language** will have its language in the URL. If this changes URLs for your site, you probably should [set up redirects](https://github.com/jekyll/jekyll-redirect-from).

If you define your own permalink style, you may use the `:lang` key like this:

```yaml
permalink: /posts/:lang/:title/
```

If you have not specified a permalink style, or if you are using one of Jekyll's default templates, your post URLs will change to include their language.
When using Jekyll's `pretty` url template, URLs will look like this:

```
/site_updates/en/2015/01/17/moving-to-a-multilingual-site/index.html
/site_updates/de/2015/01/17/umzug-in-eine-mehrsprachige-website/index.html
```

This plugin updates each of Jekyll's default permalink templates to include `:lang`.

```ruby
pretty  => /:lang/:categories/:year/:month/:day/:title/
none    => /:lang/:categories/:title.html
date    => /:lang/:categories/:year/:month/:day/:title.html
ordinal => /:lang/:categories/:year/:y_day/:title.html
```

If you don't want language to appear in your URLs, you must configure your own permalinks without `:lang`.


## Temporary language scoping

Using the `set_lang` liquid block, you can temporarily switch languages while rendering a portion of your site. For example:

```
{{ page.lang }}    # => 'en'
{{ site.posts }}   # => All posts

{% set_lang de %}
  {{ page.lang }}  # => 'de'
  {{ site.posts }} # => German posts
{% endset_lang %}

{{ page.lang }}    # => 'en'
{{ site.posts }}   # => All posts
```

The `set_lang` tag will also accept variables, for example:

```
{% assign lang = 'de' %}
{% set_lang lang %}   # equivilent to {% set_lang de %}

# On some page
{% include some_partial.html lang='de' %}

# In _includes/some_partial.html
{% set_lang include.lang %}    # equivilent to {% set_lang de %} 
```

If you have the [octopress-linkblog](https://github.com/octopress/linkblog) plugin installed, this will also change languages for your
`site.articles` and `site.linkposts` loops.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/octopress-multilingual/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
