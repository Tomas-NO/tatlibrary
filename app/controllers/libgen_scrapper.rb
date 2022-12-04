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


def mirror_getter(book_link)
  agent = Mechanize.new
  page = agent.get(book_link)

  mirror_link = page.at_xpath("//td[contains(text(),'Download')]/..//td//a/@href")
  
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

puts('This is the link to download the book:')
puts(mirror_link)
