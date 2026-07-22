---
# the default layout is 'page'
icon: fas fa-diagram-project
order: 3
---

<div class="row row-cols-1 row-cols-md-2 gx-4 gy-3">
{% assign projects = site.projects | sort: 'order' %}
{% for project in projects %}
  <div class="col">
    <div class="card h-100 shadow-sm">
      <div class="card-body d-flex flex-column">
        <div class="d-flex justify-content-between align-items-start mb-1">
          <h5 class="card-title mb-0">
            <a href="{{ project.url | relative_url }}">{{ project.title }}</a>
          </h5>
          {% if project.type %}<span class="badge bg-primary ms-2 text-nowrap">{{ project.type }}</span>{% endif %}
        </div>
        <p class="card-text">{{ project.summary }}</p>
        {% if project.highlight %}
        <p class="card-text text-muted"><small><i class="fas fa-star me-1"></i>{{ project.highlight }}</small></p>
        {% endif %}
        {% if project.tech %}
        <p class="card-text">
          {% for t in project.tech %}<span class="badge bg-secondary me-1">{{ t }}</span>{% endfor %}
        </p>
        {% endif %}
        {% if project.tags %}
        <p class="card-text">
          {% for t in project.tags %}
          <a href="{{ t | slugify | url_encode | prepend: '/tags/' | append: '/' | relative_url }}"
             class="badge bg-light text-dark border me-1 text-decoration-none">#{{ t }}</a>
          {% endfor %}
        </p>
        {% endif %}
        <div class="card-text mt-auto">
          {% if project.repo %}<a href="{{ project.repo }}" target="_blank" rel="noopener"><i class="fab fa-github me-1"></i>Code</a>{% endif %}
          {% if project.repo and project.demo %} &middot; {% endif %}
          {% if project.demo %}<a href="{{ project.demo }}" target="_blank" rel="noopener"><i class="fas fa-arrow-up-right-from-square me-1"></i>Demo</a>{% endif %}
          {% unless project.repo or project.demo %}<span class="text-muted"><small>Private repository</small></span>{% endunless %}
        </div>
      </div>
    </div>
  </div>
{% endfor %}
</div>

{% if site.projects.size == 0 %}
> Add project files under `_projects/`{: .filepath } and they'll show up here as cards.
{: .prompt-tip }
{% endif %}
