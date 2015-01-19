# Octopress Multi Language

![Build Status](http://img.shields.io/travis/octopress/multi-language.svg)](https://travis-ci.org/octopress/multi-language)
<!--[![Gem Version](http://img.shields.io/gem/v/octopress-multi-language.svg)](https://rubygems.org/gems/octopress-multi-language)-->
[![License](http://img.shields.io/:license-mit-blue.svg)](http://octopress.mit-license.org)

## Installation

If you're using bundler add this gem to your site's Gemfile in the `:jekyll_plugins` group:

    group :jekyll_plugins do
      gem 'octopress-multi-language'
    end

Then install the gem with Bundler

    $ bundle

To install manually without bundler:

    $ gem install octopress-multi-language

Then add the gem to your Jekyll configuration.

    gems:
      - octopress-multi-language


## An important note

**There is not a Jekyll standard for multi-language sites** and many plugins will not work properly with this setup. Octopress and it's
plugins are being designed to support multi-language features, but without a standard, some use-cases may be overlooked. If you have a
problem with an Octopress plugin supporting your multi-language site, please file an issue and we'll do our best to address it.

## Setting up a multi-language site

When adding this plugin to your site, you will need to:

1. Configure your site's main language, e.g. `main_language: en`.
2. Add a language to the YAML front-matter of your posts, e.g. `lang: de`.
3. Add new RSS feeds and post indexes for secondary languages.

Read on and I'll try to walk you through setting up your multi-language site. 

Note: This guide will only cover the steps listed above. Your site may still have some plugins which are not designed for multi-language sites. If you are using plugins (like a category index generator) which create pages from your site's posts, they may need to be modified or removed. Modifying plugins is beyond the scope of this guide.

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
/site_updates/en/2015/01/17/moving-to-a-multi-language-site/index.html
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
You may access secondary languages with `site.posts_by_language`.

For example, to loop through the posts written in your main language (or without a defined language) you would do this:

```
{% for post in site.posts.reverse %}
```

This is probably the way your posts index and RSS feeds are generated. If you want to loop through the posts from a secondary language — in this case, German — you would want to do this:

```
{% for post in site.posts_by_language.de.reverse %}
```

If your default post index is at `/index.html` you should create additional indexes for each secondary language. If you're also writing in German, you'd copy your posts index to `/de/index.html`.

This practice should work for RSS feeds and anything that works with the post loop.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/octopress-multi-language/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
