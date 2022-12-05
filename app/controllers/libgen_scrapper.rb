require 'mechanize'
require 'json'
require "csv"

def book_getter(book_type, book_name)
  agent = Mechanize.new
  if book_type != 'nonfic'
    page = agent.get("https://libgen.is/#{book_type}/?q=#{book_name}")

    book_link = page.at_xpath("//table[@class='catalog']//tbody//td/p/a/@href")
  else
    page = agent.get("https://libgen.is/search.php?req=#{book_name}&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def")

    book_link = page.at_xpath("//table[@class='c']//tbody//td/a[@id]/@href")
  end

  return "https://libgen.is#{book_link}"
end


def book_information_getter(book_link)
  agent = Mechanize.new
  page = agent.get(book_link)

  results = {}

  title = page.at_xpath("//td[@class = 'record_title']").text()
  author = page.at_xpath("//ul[@class = 'catalog_authors']/li | (//tr/td[contains(text(),'Authors')]/../td)[2]").text()
  image_url = "https://libgen.is#{page.at_xpath("//img/@src")}"

  results['Title'] = title
  results['Author'] = author
  if image_url != "https://libgen.is"
    results['Image'] = image_url
  else
    results['Image'] = "NO COVER"
  end

  return results
end


def mirror_getter(book_link)
  agent = Mechanize.new
  page = agent.get(book_link)
  mirror_link = []
  i = 1
  next_mirror = true

  while next_mirror
    mirror_link.append(page.at_xpath("(//td[contains(text(),'Download')]/..//td//a/@href)[#{i}]"))
    next_mirror = page.at_xpath("(//td[contains(text(),'Download')]/..//td//a/@href)[#{i + 1}]")
    i += 1
  end
  
  return mirror_link
end
      

puts('Introduce one of the followings categories:')
puts('For Non-fiction / Sci-tech: nonfic')
puts('For Fiction: fiction')
puts('For Scientific articles: scimag')
book_type = gets.chomp
puts('Introduce name of the book:')
book_name = gets.chomp.split().join('+')

book_link = book_getter(book_type, book_name)

puts('This is the link of the book:')
puts(book_link)

mirror_link = mirror_getter(book_link)

puts('This are the links to download the book:')
puts(mirror_link)

book_info = book_information_getter(book_link)

puts('This is the information of the book:')
puts(book_info)