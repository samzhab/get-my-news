## get my news
Uses https://newsapi.org to get two types of news
* top-headlines
* everything
based on specific search parameters such as country, category, language etc...

![screen capture get_my_news](https://s2.gifyu.com/images/Peek-2018-10-28-18-13.gif "Screen Sample runing the script")

Prerequisites:
* rvm (rvm.io)
* ruby interpreter (2.0+)
* required gems (see Gemfile)
* linux terminal
* newsapi Key (get one from https://newsapi.org)
* mercury apiKey (get one from https://mercury.postlight.com)

Current State:
* gets top-headlines or everything
* saves result locally as pdf format

Modules and APIs involved in this project:
* newsapi
* locate-ip api
* mercury api

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
* create folder 'articles' for articles saved as pdf
`$ mkdir articles`
* create folder 'api_keys' for various api-keys used
`$ mkdir api_keys`
* make script executable
`$ chmod +x <script_name.rb>`
* run script
`$ ./<script_name.rb>`


Further Development [coming soon...]
* Task 1 - Search DuckDuckGo for a specific term, open first 10 results
* Task 1-1 crawl their content, save them individually as pdf.
* Task 1-2 get whois info on the news outlet, where is it located, who ownes it.
* Task 2- Gather RSS feeds from prominent news outlets
