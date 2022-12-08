require 'rubygems'
require 'mechanize'
require 'json'
require "csv"

class BooksController < ApplicationController
  def index
    books_links = books_getter(params[:type], params[:search])
    @books_info = books_information_getter(books_links)
  end

  def books_getter(book_type, book_name)
    agent = Mechanize.new
    i = 1
    books_links = []
    
    if book_type == 'fiction'
      page = agent.get("https://libgen.is/#{book_type}/?q=#{book_name}")
  
      6.times {
              book_link = page.at_xpath("(//table[@class='catalog']//tbody//td/p/a/@href)[#{i}]")
              book_link = "https://libgen.is#{book_link}"
              books_links.push book_link
              i += 1
          }
      #book_link = page.at_xpath("//table[@class='catalog']//tbody//td/p/a/@href")
    elsif book_type == 'nonfic'
      page = agent.get("https://libgen.is/search.php?req=#{book_name}&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def")
      6.times {
              book_link = page.at_xpath("(//table[@class='c']//tbody//td/a[@id]/@href)[#{i}]")
              book_link = "https://libgen.is#{book_link}"
              books_links.push book_link
              i += 1
          }
    else
      page = agent.get("https://libgen.is/#{book_type}/?q=#{book_name}")
  
      6.times {
              book_link = page.at_xpath("(//table[@class='catalog']//tbody//td/p/a/@href)[#{i}]")
              book_link = "https://libgen.is#{book_link}"
              books_links.push book_link
              i += 2
          }
      #book_link = page.at_xpath("//table[@class='c']//tbody//td/a[@id]/@href")
    end
    return books_links
  end
  
  
  def books_information_getter(book_links)
    result_info = []
  
    for book_link in book_links
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
        results['Image'] = "https://libgen.is/static/no_cover.png"
      end
      results['Link'] = book_link
  
      result_info.append(results)
    end
  
    return result_info
  end

end
