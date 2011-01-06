require 'rubygems'
require 'redis'
require 'json'
require 'grit'

REPO_PATH = File.join(File.dirname(__FILE__), "..", "jruby.wiki")

redis = Redis.new
repository = Grit::Repo.new(REPO_PATH)
index = repository.index
redis.zrange("pages", 0, -1).each do |raw_page|
  page = JSON.parse(raw_page)
  puts "processing #{page['title']}, with body size of #{page['body'].size}"
  index.add("#{page['title']}.wiki", page['body'])
  actor = Grit::Actor.new(page['author'], "dev@jruby.codehaus.org")
  index.commit(page['edit_log'], [repository.commit('master')], actor, repository.commit('master').tree) 
end

