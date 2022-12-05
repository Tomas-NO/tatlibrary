require 'rubygems'
require 'mechanize'
require 'json'
require "csv"

class BookController < ApplicationController
  def index
    agent = Mechanize.new
    print(params)
    if params[:type] != 'nonfic'
      page = agent.get("https://libgen.is/#{params[:type]}/?q=#{params[:search]}")

      book_link = page.at_xpath("//table[@class='catalog']//tbody//td/p/a/@href")
    else
      page = agent.get("https://libgen.is/search.php?req=#{params[:search]}&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def")

      book_link = page.at_xpath("//table[@class='c']//tbody//td/a[@id]/@href")

    end
    @link= mirror_getter("https://libgen.is#{book_link}")
  end

  private
  def mirror_getter(book_link)
    agent = Mechanize.new
    page = agent.get(book_link)
  
    mirror_link = page.at_xpath("//td[contains(text(),'Download')]/..//td//a/@href")
    return mirror_link
  end

end
