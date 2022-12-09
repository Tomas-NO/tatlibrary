require 'mechanize'
require 'json'
require "csv"

def books_getter(book_type, book_name)
  agent = Mechanize.new
  i = 1
  books_links = []
  
  if book_type == 'fiction'
    page = agent.get("https://libgen.is/#{book_type}/?q=#{book_name}")

    6.times {
            book_link = page.at_xpath("(//table[@class='catalog']//tbody//td/p/a/@href)[#{i}]")
            break if !book_link
            book_link = "https://libgen.is#{book_link}"
            books_links.push book_link
            i += 1
        }
  elsif book_type == 'nonfic'
    page = agent.get("https://libgen.is/search.php?req=#{book_name}&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def")
    6.times {
            book_link = page.at_xpath("(//tr/td//a[@id]/@href)[#{i}]")
            break if !book_link
            book_link = "https://libgen.is/#{book_link}"
            books_links.push book_link
            i += 1
        }
  else
    page = agent.get("https://libgen.is/#{book_type}/?q=#{book_name}")

    6.times {
            book_link = page.at_xpath("(//table[@class='catalog']//tbody//td/p/a/@href)[#{i}]")
            break if !book_link
            book_link = "https://libgen.is#{book_link}"
            books_links.push book_link
            i += 2
        }
  end
  return books_links
end


def books_information_getter(book_links)
  result_info = []

  for book_link in book_links
    agent = Mechanize.new
    page = agent.get(book_link)
    results = {}
    title = page.at_xpath("//td[@class = 'record_title'] | (//tr[@valign]//a)[2]").text()
    author = page.at_xpath("//ul[@class = 'catalog_authors']/li | (//tr/td[contains(text(),'Authors')]/../td)[2] | //font[contains(text(), 'Author')]/../../../td[2]").text()
    image_url = "https://libgen.is#{page.at_xpath("//img/@src")}"

    results['Title'] = title
    results['Author'] = author
    if image_url != "https://libgen.is"
      results['Image'] = image_url
    else
      results['Image'] = "https://libgen.is/static/no_cover.png"
    end
    results['Link'] = book_link

    result_info.append(results)
  end

  return result_info
end


def mirror_getter(book_link)
  agent = Mechanize.new
  page = agent.get(book_link)
  mirror_link = []
  i = 1
  next_mirror = true

  while next_mirror
    link = page.at_xpath("(//td[contains(text(),'Download')]/..//td//a/@href)[#{i}] | (//font[contains(text(),'Mirror')]/../..//a/@href)[#{i}]").value()
    if link.include?('torrent')
      link = "https://libgen.is#{link}"
    end
    if link.include?('magnet')
      link = "https://libgen.is/book/#{link}"
    end
    mirror_link.append(link)
    next_mirror = page.at_xpath("(//td[contains(text(),'Download')]/..//td//a/@href)[#{i + 1}] | (//font[contains(text(),'Mirror')]/../..//a/@href)[#{i + 1}]")
    i += 1
  end
  
  return mirror_link
end


def books_information_detail_getter(book_link)
  agent = Mechanize.new
  page = agent.get(book_link)
  results = {}

  title = page.at_xpath("//td[@class = 'record_title'] | (//tr[@valign]//a)[2]").text()
  author = page.at_xpath("//ul[@class = 'catalog_authors']/li | (//tr/td[contains(text(),'Authors')]/../td)[2] | //font[contains(text(), 'Author')]/../../../td[2]").text()
  image_url = "https://libgen.is#{page.at_xpath("//img/@src")}"
  synopsis = page.at_xpath("(//td[@colspan = 4])[1] | (//td[@colspan = 2])[2]").text() rescue ''

  results['Title'] = title
  results['Author'] = author
  if image_url != "https://libgen.is"
    results['Image'] = image_url
  else
    results['Image'] = "https://libgen.is/static/no_cover.png"
  end
  results['Synopsis'] = synopsis
  results['Mirrors'] = mirror_getter(book_link)

  return results
end


puts('Introduce one of the followings categories:')
puts('For Non-fiction / Sci-tech: nonfic')
puts('For Fiction: fiction')
puts('For Scientific articles: scimag')
book_type = gets.chomp
puts('Introduce name of the book:')
book_name = gets.chomp.split().join('+')

books_links = books_getter(book_type, book_name)

list_info = books_information_getter(books_links)
    puts('This is the information of the book')
    puts(list_info)

books_links.each do |book_link|
    puts('This is the link of the book:')
    puts book_link

    book_details = books_information_detail_getter(book_link)
    puts('This are the details to download the book:')
    puts(book_details)
end
