<!--
Add here global page variables to use throughout your website.
-->
+++
author = "Bilevel Optimization Research Group"
mintoclevel = 2

# Add here files or directories that should be ignored by Franklin, otherwise
# these files might be copied and, if markdown, processed by Franklin which
# you might not want. Indicate directories by ending the name with a `/`.
# Base files such as LICENSE.md and README.md are ignored by default.
ignore = ["node_modules/", "Project.toml", "Manifest.toml", "bib/", "members/members.csv"]

# RSS (the website_{title, descr, url} must be defined to get RSS)
generate_rss = true
website_title = "BORG"
website_descr = "We are a team of researchers focused on advancing the field of bilevel optimization."
website_url   = "https://group.bi-level.org/"
hasbanner = false
website_mantainer = "Jesús-Adolfo Mejía-de-Dios"
+++

<!--
Add here global latex commands to use throughout your pages.
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}

\newcommand{\photo}[2]{
~~~
<img src="!#2" alt="Photo of #1" style="max-width:300px;padding:1.5em;"  align="left"/>
~~~
}
