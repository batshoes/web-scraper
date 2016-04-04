require 'mechanize'
require 'pry'
require 'csv'

scraper = Mechanize.new
scraper.history_added = Proc.new { sleep 0.5 }
ADDRESS = "http://www.usacreditunions.com/"
results = []


for i in 1..208 do
  base_url = "http://www.usacreditunions.com/usa-credit-unions-deposit-rates-page#{i}"

  scraper.get(base_url) do |search|
    union_list = search.css('.cusview').css('.cuitem').css('.tdrates').css('span').css('a[href]')
    
    union_list.each do |l|
      href = ADDRESS + l.attributes['href'].value
      results_hash = {
        name: l.text,
        href: href
      }
      
      results << results_hash
    end
  end
end

results.each do |site|
  scraper.get("#{site[:href]}") do |data_search|
    result_array = []
    
    info_paragraph = data_search.css('.intro')
    asset = info_paragraph.text[/\$(.*?)[^\.]*/]
    site[:assets] = asset

    data_search.css('.infoTables').css('.row-detail')[0..27].each do |val|
      result_array << val.text
    end

    results_hash = Hash[*result_array]
    
    results_hash.keys.each do |key|
      site[key] = results_hash[key]
    end

  end
  puts site[:name] + " done..."
end

CSV.open("usa-credit-unions.csv", "wb") do |csv|
  csv << results.first.keys # adds the attributes name on the first line
  results.each do |hash|
    csv << hash.values
  end
end