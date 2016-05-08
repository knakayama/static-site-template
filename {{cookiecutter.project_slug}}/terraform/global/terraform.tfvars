# Global
name = "static-site-template"

region = "{{ cookiecutter.region }}"

iam_admins = "static-site-admin"

site_domain = "{{ cookiecutter.site_domain.rstrip('.') }}"

static_site_sub_domain = "{{ cookiecutter.static_site_sub_domain }}"
