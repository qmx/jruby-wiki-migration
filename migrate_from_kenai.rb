# stupid script to ripoff jruby's wiki from kenai
# any improvements are more than welcome!
# btw, currently broken **WIP**
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'reverse_markdown'
require 'fileutils'

KENAI_BASE = "http://kenai.com"
BASEDIR = "./out"

def fetch_links(url = "#{KENAI_BASE}/projects/jruby/pages/Home")
  data = open(url).read
  doc = Nokogiri::HTML(data)
  pages = {}
  doc.xpath("//a").each do |x|
    if x[:href] =~ /jruby\/pages/ && !(x[:href] =~ /#/)
      pages.update({x.content => x[:href]})
    end
  end
  pages
end

def fetch_page(link)
  begin
    data = open(link).read
    doc = Nokogiri::HTML(data).xpath("//div[@class='wikiMainBody']").first
  rescue RuntimeError => e
    doc = ''
  end
  if doc.respond_to?(:to_xhtml)
    doc.to_xhtml
  else
    ""
  end
end

def convert_to_markdown(xhtml)
  r = ReverseMarkdown.new
  r.parse_string(xhtml)
end

def convert!
  links = fetch_links
  links.each do |title, link|
    if title 
      url = "#{KENAI_BASE}#{link}"
      puts "#{title}=>#{url}"
      page = convert_to_markdown(fetch_page(url))
      target = "#{BASEDIR}#{link}.markdown"
      FileUtils.mkdir_p(File.dirname(target))
      f = File.new(target, "w+")
      f.write(page)
      f.close
      puts "#{page}"
    end
  end
end

