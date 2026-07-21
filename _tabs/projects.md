---
# the default layout is 'page'
icon: fas fa-diagram-project
order: 3
---

<div class="row row-cols-1 row-cols-md-2 g-3">
{% assign projects = site.projects | sort: 'order' %}
{% for project in projects %}
  <div class="col">
    <div class="card h-100 shadow-sm">
      <div class="card-body">
        <h5 class="card-title">
          <a href="{{ project.url | relative_url }}">{{ project.title }}</a>
        </h5>
        <p class="card-text">{{ project.summary }}</p>
        {% if project.tech %}
        <p class="card-text">
          {% for t in project.tech %}<span class="badge bg-secondary me-1">{{ t }}</span>{% endfor %}
        </p>
        {% endif %}
        <div class="card-text">
          {% if project.repo %}<a href="{{ project.repo }}" target="_blank" rel="noopener">Code</a>{% endif %}
          {% if project.repo and project.demo %} &middot; {% endif %}
          {% if project.demo %}<a href="{{ project.demo }}" target="_blank" rel="noopener">Live demo</a>{% endif %}
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
