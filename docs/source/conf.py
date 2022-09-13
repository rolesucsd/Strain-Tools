# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'strain-tools'
copyright = '2022, Renee Oles'
author = 'Renee Oles'
release = 'Sep 2022'

import sphinx_rtd_theme

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

# source_suffix = ['.rst', '.md']
source_suffix = '.rst'

# The master toctree document.
master_doc = 'index'

extensions = []
templates_path = ['_templates']
exclude_patterns = []

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = False

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_theme_options = {
  'display_version': False,
  'navigation_depth': 2,
  'collapse_navigation': True
}
html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]
html_last_updated_fmt = '%b %d, %Y'
html_context = {
  'display_github': True,
  'github_user': 'Uberspace',
  'github_repo': 'manual',
  'github_version': 'main',
  'conf_py_path': '/source/',
  'changelog_entries': changelog_entries,
  'newest_changelog_entry': changelog_entries[0],
}
html_show_copyright = False
html_favicon = '_static/favicon.ico'
html_css_files = [
    'css/custom.css',
]
html_static_path = ['_static']


html_sidebars = {
    '**': [
        'relations.html',  # needs 'show_related': True theme option to display
        'searchbox.html',
    ]
}



