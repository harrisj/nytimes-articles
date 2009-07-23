# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nytimes-articles}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jacob Harris"]
  s.date = %q{2009-07-23}
  s.description = %q{A gem for accessing the New York Times Article Search API}
  s.email = %q{jharris@nytimes.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    ".gitignore",
     "HISTORY",
     "LICENSE",
     "README",
     "Rakefile",
     "VERSION.yml",
     "features/nytimes_articles.feature",
     "features/steps/nytimes_articles_steps.rb",
     "features/support/env.rb",
     "lib/nytimes_articles.rb",
     "lib/nytimes_articles/article.rb",
     "lib/nytimes_articles/base.rb",
     "lib/nytimes_articles/exceptions.rb",
     "lib/nytimes_articles/facet.rb",
     "lib/nytimes_articles/facet_hash.rb",
     "lib/nytimes_articles/query.rb",
     "lib/nytimes_articles/result_set.rb",
     "lib/nytimes_articles/thumbnail.rb",
     "nytimes-articles.gemspec",
     "script/console",
     "test/nytimes/articles/test_article.rb",
     "test/nytimes/articles/test_base.rb",
     "test/nytimes/articles/test_facet.rb",
     "test/nytimes/articles/test_query.rb",
     "test/nytimes/articles/test_result_set.rb",
     "test/nytimes/articles/test_thumbnail.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/harrisj/nytimes-articles}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.requirements = ["Unicode", "The htmlentities gem"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A gem for accessing the NYTimes Article Search API}
  s.test_files = [
    "test/nytimes/articles/test_article.rb",
     "test/nytimes/articles/test_base.rb",
     "test/nytimes/articles/test_facet.rb",
     "test/nytimes/articles/test_query.rb",
     "test/nytimes/articles/test_result_set.rb",
     "test/nytimes/articles/test_thumbnail.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<htmlentities>, [">= 0"])
    else
      s.add_dependency(%q<htmlentities>, [">= 0"])
    end
  else
    s.add_dependency(%q<htmlentities>, [">= 0"])
  end
end
