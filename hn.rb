require 'mechanize'

module HNScraper

  def self.get_stories(number=10)
    get_pages(number.to_i)
  end

  def self.pretty_print(number=10)
    get_stories(number).each do |story|
      puts
      puts "#{story[:text]} - #{story[:url]}"
    end
    puts

    true
  end

  private

  def self.get_pages(number_of_stories)
    agent = Mechanize.new
    stories = []
    page = agent.get("http://news.ycombinator.com/")
    stories += parse_page(page)
    while stories.count < number_of_stories
      page = agent.page.link_with(:text => 'More').click
      stories += parse_page(page)
    end

    stories[0...number_of_stories]
  end

  def self.parse_page(page)
    titles = page.search('.title')
    stories = titles.get_odd
    articles = stories.flat_map do |story|
      story.first.search('a').map do |s1|
        article = {}
        article[:text] = s1.text
        article[:url] = s1['href']

        article
      end
    end

    articles
  end
end

class Nokogiri::XML::NodeSet
  ["odd", "even"].each do |bool|
    define_method "get_#{bool}" do
      each_with_index.select do |_, i|
        i.send(bool + "?")
      end
    end
  end
end
