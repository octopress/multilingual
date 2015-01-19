# Octopress Multilingual

Add multiple language features to your Jekyll site.

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

**There is not a Jekyll standard for multilingual sites** and many plugins will not work properly with this setup. Octopress and it's
plugins are being designed to support multilingual features, but without a standard, some use-cases may be overlooked. If you have a
problem with an Octopress plugin supporting your multilingual site, please file an issue and we'll do our best to address it.

## Setting up a multilingual site

When adding this plugin to your site, you will need to:

1. Configure your site's main language, e.g. `main_language: en`.
2. Add a language to the YAML front-matter of your posts, e.g. `lang: de`.
3. Add new RSS feeds and post indexes for secondary languages.

Read on and I'll try to walk you through setting up your multilingual site. 

Note: This guide will only cover the steps listed above. Your site may still have some plugins which are not designed for multilingual sites. If you are using plugins (like a category index generator) which create pages from your site's posts, they may need to be modified or removed. Modifying plugins is beyond the scope of this guide.

## Configuration

First, be sure to configure your Jekyll site's main language, for example:

```yaml
main_language: en
```

Here we are setting the default language to English. Posts without a defined language will be treated as English posts.

## Defining a post's language

Posts should specify their language in the YAML front matter. 

```yaml
title: "Ein Nachdenklich Beitrag"
lang: de
```

If you are using Octopress, you can easily create a new post with the language already site like this:

```
$ octopress new post "Some title" --lang en
```

### Cross-posting languages

Occasionally you may wish to write a post in a single language and have it show up in other languages indexes and feeds. This can be done in your post's YAML front-matter:

```
title: "Ein Nachdenklich Beitrag"
lang: de
crosspost_languages: true
```

If your site has language-specific feeds or post indexes, a post with this setting will show up in all of them. However, it isn't duplicated. It will still have one canonical URL.

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

## Post Indexes and RSS Feeds

This plugin modifies your site's post list. The `site.posts` array **will not contain every post**, but only posts defined with your site's main language or with no language defined.

Using the `post_lang` liquid block, set the language for posts in your post loop. Here's how to use it:

```
# Standard post loop (loops through main language)
{% for post in site.posts %}...{% endfor %}

# Loop through german posts (and crossposts)
{% post_lang de %}
{% for post in site.posts %}...{% endfor %}
{% endpost_lang %}
```

If your default post index is at `/index.html` you should create additional indexes for each secondary language. If you're also writing in German, create a posts index at `/de/index.html`.

DRY up your templates by putting post loops in an include. 

<!-- title:"From /index.html" -->
```
# Render main language post index
{% include post-index.html %}
```

<!-- title:"From /de/index.html" -->
```
# Render German post index
{% include post-index.html lang='de' %}
```

The post loop in your `_includes/post-index.html` file would look
like this:

<!-- title:"From _includes/post-index.html" -->
```
{% post_lang include.lang %}
{% for post in site.posts %}...{% endfor %}
{% endpost_lang %}
```

This approach should work for RSS feeds and anything that works with the post loop.

## Reference posts by language

You may also access secondary languages directly with `site.posts_by_language`.

For example, to loop through the posts written in your main language (or those with no defined language) you would do this:

```
{% for post in site.posts %}
```

If you want to loop through the posts from a secondary language — in this case, German — you would want to do this:

```
{% for post in site.posts_by_language.de %}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/octopress-multilingual/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
