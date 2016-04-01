require 'mechanize'
require 'pry'
require 'csv'

scraper = Mechanize.new
scraper.history_added = Proc.new { sleep 0.5 }
ADDRESS = "http://www.usacreditunions.com/"
link_results = []
data_results = []


for i in 1..2 do
  base_url = "http://www.usacreditunions.com/usa-credit-unions-deposit-rates-page#{i}"

  scraper.get(base_url) do |search|
    union_list = search.css('.cusview').css('.cuitem').css('.tdrates').css('span').css('a[href]')
    
    union_list.each do |l|
      results_hash = {
        name: l.text,
        href: l.attributes['href'].value
      }
      
      link_results << results_hash
    end
  end
end
puts link_results

link_results.each do |site|
  scraper.get(ADDRESS + "#{site[:href]}") do |data_search|
    

    total_assets = data_search.css('.intro')
    number = total_assets.text[/\$(.*?)[^\.]*/]
    data_results << number
  end
end
puts data_results