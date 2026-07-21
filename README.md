# blog-site

Personal site for posting projects and research write-ups, built with
[Jekyll][jekyll] and the [Chirpy][chirpy] theme, hosted on GitHub Pages.

Live at: https://imndllnuri.github.io/blog-site/

## Structure

- `_posts/` — blog posts & research write-ups
- `_projects/` — one file per project, rendered as cards on the
  [Projects](https://imndllnuri.github.io/blog-site/projects/) tab
- `_tabs/` — top-level nav pages (About, Projects, Archives, Categories, Tags)

## Local development

```shell
bundle install
bundle exec jekyll serve
```

Then open http://127.0.0.1:4000/blog-site/.

## Deployment

Pushing to `main` triggers `.github/workflows/pages-deploy.yml`, which builds
the site and deploys it via GitHub Pages (Settings → Pages → Source →
**GitHub Actions**).

## Credits

Scaffolded from [chirpy-starter][starter], a template for the [Chirpy][chirpy]
Jekyll theme.

[jekyll]: https://jekyllrb.com/
[chirpy]: https://github.com/cotes2020/jekyll-theme-chirpy/
[starter]: https://github.com/cotes2020/chirpy-starter
