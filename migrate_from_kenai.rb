# stupid script to ripoff jruby's wiki from kenai
# any improvements are more than welcome!
# btw, currently broken **WIP**
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'json'

KENAI_BASE = "https://kenai.com/api/projects/jruby/features/wiki/pages.json"
INPUT = "./in"
BASEDIR = "./out"
PANDOC = "$HOME/.cabal/bin/pandoc"

def fetch_pages
  result = JSON.parse(open(KENAI_BASE).read)
  loop do
    result['pages'].each do |page|
      page_url = page['href']
      puts page_url
      page_data = JSON.parse(open(page_url).read)
      revisions = JSON.parse(open(page_data['revisions_href']).read)
      loop do
        revisions['revisions'].each do |page_revision|
          rev_number = page_revision['number']
          page_name = page['name']
          puts "processing page #{page_name}, revision #{rev_number}"
          current_revision_dir = "#{INPUT}/#{rev_number}"
          FileUtils.mkdir_p(current_revision_dir)
          raw_data = open(page_revision['href']).read
          #parsed_data = JSON.parse(raw_data)
          #f = File.new("#{current_revision_dir}/#{page_name}.wiki", "w+")
          #f.write(raw_data['text'])
          #f.close
          f_raw = File.new("#{current_revision_dir}/#{page_name}.json", "w+")
          f_raw.write(raw_data)
          f_raw.close
        end
        revisions = JSON.parse(open(revisions['next']).read) if revisions['next']
        break unless revisions['next']
      end
    end
    result = JSON.parse(open(result['next']).read) if result['next']
    break unless result['next']
  end
end

