## get my news
Uses https://newsapi.org to get two types of news
* top-headlines
* everything
based on specific search parameters such as country, category, language etc...

Prerequisites:
* rvm (rvm.io)
* ruby interpreter (2.0+)
* required gems (see Gemfile)
* linux terminal

Current State:
* gets top-headlines or everything
* saves result locally as pdf format

Features to add [coming soon...]
* add sortBy to queries

Setup usage with rvm and process event series:
* create a gemset
`$ rvm gemset create <gemset>`
eg. `$ rvm gemset create get_my_news`
* use created gemset
`$ rvm <ruby version>@<gemset>`
* install bundler gem
`$ gem install bundler`
* install necessary gems
`$ bundle`
* create folder 'articles'
`$ mkdir articles`
* make script executable
`$ chmod +x <script_name.rb>`
* run script
`$ ./<script_name.rb>`


Further Development [coming soon...]
* Task 1 - Search DuckDuckGo for a specific term, open first 10 results
* Task 1-1 crawl their content, save them individually as pdf.
* Task 1-2 get whois info on the news outlet, where is it located, who ownes it.
* Task 2- Gather RSS feeds from prominent news outlets
