# Changelog

### 0.2.0 (2015-02-02)
- Added a `language_name` method for retrieving a match from the language_names hash.

### 0.2.0 (2015-02-02)
- Link between posts or pages with a matching `translation_id`.
- Add translation IDs to posts or pages with `octopress translate <path>`.
- Check if a post or page has been translated with `[post or page].tranlsated`.
- Access translated posts or pages with `[post or page].tranlsations`.
- New tags `{% translations [post or page] %}` and `{% translation_list [post or page] %}` for generating links to translated posts.
- Convert language codes to language names with filter `{{ de | language_name }}`.

### 0.1.4 (2015-02-01)
- Cross-post languages with `lang_crosspost: true` in a post's YAML front-matter.

### 0.1.3 (2015-01-31)
- Fix: 'default' language maps to site.lang.
- Fix: Issue with access to site instance.

### 0.1.2 (2015-01-31)
- Now pages can use the /:lang/ permalink placeholder.
- New site methods: `posts_by_language`, `articles_by_language`, `linkposts_by_language`, `languages`.

### 0.1.1 (2015-01-30)
- Fix: On pages, `lang: default` now defaults to `site.lang`.

### 0.1.0 (2015-01-30)
- Change: No longer filters `site.posts` at all.
- Change: Posts are automatically filtered based on `page.lang`.
- Docs have been improved quite a bit.

### 0.0.9 (2015-01-25)
- Fix: Language cross-posts are now properly sorted. Thanks @drallgood, via [#6](https://github.com/octopress/multilingual/pull/6).

### 0.0.8 (2015-01-21)
- Fix: on posts, page.next and page.previous follow post language

### 0.0.7 (2015-01-21)

- Fix: If no posts had been defined with the main language, posts would disappear. Most embarrassing.
- Change: instead of `site.main_language`, now using `site.lang`.

### 0.0.6 (2015-01-20)

- Reversed post order (as it should be)

### 0.0.5 (2015-01-19)

- Improved integration with Octopress docs

### 0.0.4 (2015-01-19)

- Added support for scoping octopress-linkblog `articles` and `linkposts` loops.

### 0.0.3 (2015-01-19)

- Renamed tag to `{% set_lang %}`.

### 0.0.2 (2015-01-19)

- New: `{% post_lang %}` block tag.

### 0.0.1 (2015-01-18)

- initial release
