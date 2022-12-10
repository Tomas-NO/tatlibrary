require 'rubygems'
require 'mechanize'
require 'json'
require "csv"

class BookController < ApplicationController
  def index
    agent = Mechanize.new
    page = agent.get(params[:link])
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
    results['Mirrors'] = mirror_getter(params[:link])
  
    @book_info = results  
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
end