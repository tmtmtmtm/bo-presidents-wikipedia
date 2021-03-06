#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require_relative 'lib/partial_date'
require_relative 'lib/unspan_all_tables'
require_relative 'lib/wikipedia_table_row'

# The Wikipedia page with a list of officeholders
class ListPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links
  decorator UnspanAllTables

  field :officeholders do
    list.xpath('.//tr[td]').map { |td| fragment(td => HolderItem) }.reject(&:empty?).map(&:to_h).uniq(&:to_s)
  end

  private

  def list
    noko.xpath('.//table[.//th[contains(
      translate(., "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"),
    "fin du mandat")]]')
  end
end


# Each officeholder in the list
class HolderItem < WikipediaTableRow
  field :ordinal do
    tds[0].text.to_i
  end

  field :id do
    wikidata_ids_in(tds[1]).first
  end

  field :name do
    link_titles_in(tds[1]).first
  end

  field :start_date do
    tds[2].css('time/@datetime')
  end

  field :end_date do
    tds[3].css('time/@datetime')
  end

  field :replaces do
  end

  field :replaced_by do
  end

  def empty?
    name.to_s == ''
  end
end

url = ARGV.first || abort("Usage: #{$0} <url to scrape>")
data = Scraped::Scraper.new(url => ListPage).scraper.officeholders

data.each_cons(2) do |prev, cur|
  cur[:replaces] = prev[:id]
  prev[:replaced_by] = cur[:id]
end

header = data[1].keys.to_csv
rows = data.map { |row| row.values.to_csv }
puts header + rows.join
