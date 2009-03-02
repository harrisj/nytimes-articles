# should I be setting this?
$KCODE = 'UTF8'

%w(exceptions base facet thumbnail article result_set query).each do |f|
  require File.join(File.dirname(__FILE__), 'nytimes_articles', f)
end
