---
title: "Browse Tags"
layout: default
permalink: /tags/
---

<ul>
  {% assign tags = site.tags | sort %}
  {% for tag in tags %}
    <li>
      <a href="/tags/{{ tag[0] | slugify }}.html">{{ tag[0] }}</a>
      ({{ tag[1].size }})
    </li>
  {% endfor %}
</ul>
