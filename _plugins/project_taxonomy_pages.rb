#!/usr/bin/env ruby
#
# jekyll-archives builds /tags/:name/ and /categories/:name/ pages purely
# from site.tags/site.categories, which Jekyll core only ever populates
# from the `posts` collection. That leaves no archive page at all for a
# tag/category used exclusively by a `_projects` entry. This generator
# fills that gap by creating the missing pages (using the site's own
# `tag`/`category` layouts) for any project-only tag/category.

module ProjectTaxonomyPages
  class TaxonomyPage < Jekyll::PageWithoutAFile
    def initialize(site, dir, layout, title)
      @site = site
      @base = site.source
      @dir  = dir
      @name = "index.html"
      process(@name)
      self.data = {
        "layout" => layout,
        "title"  => title,
      }
      self.content = ""
    end
  end

  class Generator < Jekyll::Generator
    safe true

    def generate(site)
      projects = site.collections["projects"] ? site.collections["projects"].docs : []

      project_tags = projects.flat_map { |doc| doc.data["tags"] || [] }.uniq
      (project_tags - site.tags.keys).each do |tag|
        dir = File.join("tags", Jekyll::Utils.slugify(tag))
        site.pages << TaxonomyPage.new(site, dir, "tag", tag)
      end

      project_categories = projects.map { |doc| doc.data["category"] }.compact.uniq
      (project_categories - site.categories.keys).each do |category|
        dir = File.join("categories", Jekyll::Utils.slugify(category))
        site.pages << TaxonomyPage.new(site, dir, "category", category)
      end
    end
  end
end
