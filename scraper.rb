require 'mechanize'
require 'pry'
require 'csv'

scraper = Mechanize.new
scraper.history_added = Proc.new { sleep 0.5 }
ADDRESS = "http://www.usacreditunions.com/"
results = []


for i in 1..2 do
  base_url = "http://www.usacreditunions.com/usa-credit-unions-deposit-rates-page#{i}"

  scraper.get(base_url) do |search|
    union_list = search.css('.cusview').css('.cuitem').css('.tdrates').css('span').css('a[href]')
    
    union_list.each do |l|
      results_hash = {
        name: l.text,
        href: l.attributes['href'].value
      }
      
      results << results_hash
    end
  end
end
puts "Found names and href's"

results.each do |site|
  scraper.get(ADDRESS + "#{site[:href]}") do |data_search|
    

    info_paragraph = data_search.css('.intro')
    asset = info_paragraph.text[/\$(.*?)[^\.]*/]
    email = info_paragraph.text #email regex
    phone = info_paragraph.text #phone regex
    site[:assets] = asset
  end
end
puts "Added all numeric values"

CSV.open("test.csv", "wb") do |csv|
  csv << results.first.keys # adds the attributes name on the first line
  results.each do |hash|
    csv << hash.values
  end
end