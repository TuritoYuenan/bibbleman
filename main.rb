# frozen_string_literal: true

require 'tty-prompt'
require 'json'

#  _   _ _   _ _ _ _   _
# | | | | | (_) (_) | (_)
# | | | | |_ _| |_| |_ _  ___  ___
# | | | | __| | | | __| |/ _ \/ __|
# | |_| | |_| | | | |_| |  __/\__ \
#  \___/ \__|_|_|_|\__|_|\___||___/

def add_date
  prompt = TTY::Prompt.new
  months = %w[
    Unknown January February March April May June
    July August September October November December
  ]

  year = prompt.ask('Enter year:', default: '2000') { |q| q.in('0000-2111') }
  month = prompt.select('Enter month:', months)
  day = prompt.ask('Enter day:', default: '31') { |q| q.in('0-31') }
  [year, month, day]
end

def add_doi
  doi_query = 'Digital Object Identifier:'
  TTY::Prompt.new.ask(doi_query, default: '10.XXXX/abc.1234.ef') do |q|
    q.validate(/\b(10[.][0-9]{4,}(?:[.][0-9]+)*(?:(?!["&'])\S)+)\b/)
  end
end

def add_authors
  prompt = TTY::Prompt.new
  count_query = 'How many authors are involved? (0 for organisational)'
  count = prompt.ask(count_query, default: 1, convert: :integer) { |q| q.in('0-30') }

  if count.zero?
    org_query = "Enter the organisation's name:"
    organisation = prompt.ask(org_query, default: 'Place Holder inc.')
    [0, organisation]
  end

  authors = []

  index = 0
  while index < count
    author = prompt.ask('Author name:', default: 'John Doe') { |q| q.required true }
    authors << author
    index += 1
  end
  authors
end

def read_author(file)
  count = file.gets.to_i
  if count.zero?
    organisation = file.gets.chomp
    [0, organisation]
  end

  authors = []
  count.times do
    author = file.gets.chomp
    authors << author
  end
  authors
end

def print_author(authors)
  if (authors[0]) == 0
    puts(authors[1])
    return nil
  end

  count = authors.length
  count.times do |i|
    if i == count - 1
      puts(authors[i])
    else
      print("#{authors[i]}, ")
    end
  end
end

def write_author(file, authors)
  if authors[0] == 0
    p("export organisation")
    file.puts(0)
    file.puts(authors[1])
    return nil
  end

  count = authors.length
  file.puts(count)
  count.times { |i| file.puts(authors[i]) }
end

# ______             _
# | ___ \           | |
# | |_/ / ___   ___ | | __
# | ___ \/ _ \ / _ \| |/ /
# | |_/ / (_) | (_) |   <
# \____/ \___/ \___/|_|\_\

# Book source: Author, Title, Publication Year, Publisher
class Book
	attr_accessor :author, :title, :year, :publisher

	def initialize(author, title, year, publisher)
		@author = author
		@title = title
		@year = year
		@publisher = publisher
	end

	def write(file)
		write_author(file, @author)
		file.puts(@title)
		file.puts(@year)
		file.puts(@publisher)
	end
end

def read_book(file)
	author = read_author(file)
	title = file.gets.chomp
	year = file.gets.to_i
	publisher = file.gets.chomp

	Book.new(author, title, year, publisher)
end

def add_book
	prompt = TTY::Prompt.new

	author = add_authors
	title = prompt.ask('Title:', default: 'Nineteen Eighty-Four')
	year = prompt.ask('Publication year:', default: 1949, convert: :integer)
	publisher = prompt.ask('Publisher:', default: 'Secker & Warburg')

	Book.new(author, title, year, publisher)
end

def print_book(book)
	print("#{book.title} (#{book.year}) by ")
	print_author(book.author)
	puts("Published by #{book.publisher}")
end

#   ___       _   _      _
#  / _ \     | | (_)    | |
# / /_\ \_ __| |_ _  ___| | ___
# |  _  | '__| __| |/ __| |/ _ \
# | | | | |  | |_| | (__| |  __/
# \_| |_/_|   \__|_|\___|_|\___|

# Journal Article source: Author, Title, Publication year, Journal
# Volume, Issue, Page range, Digital Object Identifier
class Article
	attr_accessor :author, :title, :year, :journal, :volume, :issue, :page, :doi

	def initialize(author, title, year, journal, volume, issue, page, doi)
		@author = author
		@title = title
		@year = year
		@journal = journal
		@volume = volume
		@issue = issue
		@page = page
		@doi = doi
	end

	def write(file)
		write_author(file, @author)
		file.puts(@title)
		file.puts(@year)
		file.puts(@journal)
		file.puts(@volume)
		file.puts(@issue)
		file.puts(@page)
		file.puts(@doi)
	end
end

def read_article(file)
	author = read_author(file)
	title = file.gets.chomp
	year = file.gets.to_i
	journal = file.gets.chomp
	volume = file.gets.to_i
	issue = file.gets.to_i
	page = file.gets.chomp
	doi = file.gets.chomp

	Article.new(author, title, year, journal, volume, issue, page, doi)
end

def add_article
	prompt = TTY::Prompt.new
	author = add_authors
	title = prompt.ask('Title:', default: 'Lorem Ipsum: Dolor Sit Amet')
	year = prompt.ask('Publish year:', default: '2023', convert: :integer) do |q|
		q.validate(/\d{4,}/)
	end
	journal = prompt.ask('Name of the Journal:', default: 'Journal of Marine Biology')
	volume = prompt.ask('Volume number:', convert: :integer)
	issue = prompt.ask('Issue number:', convert: :integer)
	page_range = prompt.ask('Page range:', default: '000-000') do |q|
		q.validate(/\d{1,}-\d{1,}/)
	end
	doi = add_doi

	Article.new author, title, year, journal, volume, issue, page_range, doi
end

def print_article(article)
	puts(article.title)
	print('by ')
	print_author(article.author)
	puts("Published by #{article.journal}")
	print("Volume #{article.volume}") if article.volume
	puts(", Issue #{article.issue}") if article.issue
	puts("Page #{article.page}") if article.page
	puts("https://doi.org/#{article.doi}") if article.doi
end

#  _    _      _
# | |  | |    | |
# | |  | | ___| |__  _ __   __ _  __ _  ___
# | |/\| |/ _ \ '_ \| '_ \ / _` |/ _` |/ _ \
# \  /\  /  __/ |_) | |_) | (_| | (_| |  __/
#  \/  \/ \___|_.__/| .__/ \__,_|\__, |\___|
#                   | |           __/ |
#                   |_|          |___/

# Webpage Document source: Author, Title, Publication date, Website name, URL
class Webpage
	attr_accessor :author, :title, :date, :website, :url

	def initialize(author, title, date, website, url)
		@author = author
		@title = title
		@date = date
		@website = website
		@url = url
	end

	def write(file)
		write_author(file, @author)
		file.puts(@title)
		file.puts(@date)
		file.puts(@website)
		file.puts(@url)
	end
end

def read_webpage(file)
	author = read_author(file)
	title = file.gets.chomp
	date = file.gets.chomp
	website = file.gets.chomp
	url = file.gets.chomp

	Webpage.new(author, title, date, website, url)
end

def add_webpage
	prompt = TTY::Prompt.new
	author = add_authors
	title = prompt.ask('Enter webpage title:', default: 'Lorem ipsum - Dolor Sit Amet')
	date = add_date
	website = prompt.ask('Enter website name:', default: 'Place Holder inc.')
	url = prompt.ask('Enter URL:') do |q|
		q.validate(%r{(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])})
	end

	Webpage.new(author, title, date, website, url)
end

def print_webpage(webpage)
	print(webpage.title)
	puts("by #{webpage.author}")
	puts("Uploaded on #{webpage.website}, #{webpage.date}")
	puts(webpage.url)
end

# ______ _ _     _ _                             _
# | ___ (_) |   | (_)                           | |
# | |_/ /_| |__ | |_  ___   __ _ _ __ __ _ _ __ | |__  _   _
# | ___ \ | '_ \| | |/ _ \ / _` | '__/ _` | '_ \| '_ \| | | |
# | |_/ / | |_) | | | (_) | (_| | | | (_| | |_) | | | | |_| |
# \____/|_|_.__/|_|_|\___/ \__, |_|  \__,_| .__/|_| |_|\__, |
#                           __/ |         | |           __/ |
#                          |___/          |_|          |___/

def add_bibliography_item
  types = %w[Book Article Webpage]
  type = TTY::Prompt.new.select('Which type of item do you want to add?', types)
  case type
  when types[0]
    item = add_book
  when types[1]
    item = add_article
  when types[2]
    item = add_webpage
  end
  item
end

def print_bibliography(bibliography)
  bibliography.each do |item|
    case item.class.name
    when 'Book'
      print_book(item)
    when 'Article'
      print_article(item)
    when 'Webpage'
      print_webpage(item)
    else
      p(item)
    end
    puts('') # Add spacing between each item
  end
end

def read_bibliography(bibfile)
  bibliography = []
  count = bibfile.gets.to_i
  p(count)

  count.times do
    type = bibfile.gets.chomp
    case type
    when 'Book'
      item = read_book(bibfile)
    when 'Article'
      item = read_article(bibfile)
    when 'Webpage'
      item = read_webpage(bibfile)
    else
      puts('Unknown item type')
    end
    bibliography << item
  end

  bibliography
end

def write_bibliography(bibfile, bibliography)
  # Write number of bibliography items
  bibfile.puts(bibliography.length)
  # Write each item using Object Polymorphism
  bibliography.each do |item|
    bibfile.puts(item.class.name)
    item.write(bibfile)
  end
end

# ___  ___      _        ______
# |  \/  |     (_)       | ___ \
# | .  . | __ _ _ _ __   | |_/ / __ ___   __ _ _ __ __ _ _ __ ___
# | |\/| |/ _` | | '_ \  |  __/ '__/ _ \ / _` | '__/ _` | '_ ` _ \
# | |  | | (_| | | | | | | |  | | | (_) | (_| | | | (_| | | | | | |
# \_|  |_/\__,_|_|_| |_| \_|  |_|  \___/ \__, |_|  \__,_|_| |_| |_|
#                                         __/ |
#                                        |___/

def main
  bibfile_name = 'bibfile.txt' # Default file name
  bibarray = [] # Array of Bibliography items

  header = [
    ' ____ ___ ____  ____  _     __  __    _    _   _',
    '| __ )_ _| __ )| __ )| |   |  \/  |  / \  | \ | |',
    '|  _ \| ||  _ \|  _ \| |   | |\/| | / _ \ |  \| |',
    '| |_) | || |_) | |_) | |___| |  | |/ ___ \| |\  |',
    '|____/___|____/|____/|_____|_|  |_/_/   \_\_| \_|',
  ]

  choices = [
    'Open file',
    'Save file',
    'Add item to bibliography',
    'Print bibliography',
    'Exit (Lose unsaved changes)'
  ]

  prompt = TTY::Prompt.new
  header.each { |i| prompt.warn(i) }
  puts('')

  done = false
  loop do
    choice = prompt.select('Main Menu', choices)
    case choice
    when choices[0]
      bibfile_name = prompt.ask('Enter file name to import:', default: bibfile_name)

      bibfile = File.new(bibfile_name, 'r')
      bibarray = read_bibliography(bibfile)
      bibfile.close

      prompt.ok("Opened #{bibfile_name} file!")
    when choices[1]
      bibfile_name = prompt.ask('Enter file name to export:', default: bibfile_name)

      bibfile = File.new(bibfile_name, 'w')
      write_bibliography(bibfile, bibarray)
      bibfile.close

      prompt.ok("Saved to #{bibfile_name} file!")
    when choices[2]
      item = add_bibliography_item
      bibarray << item
      puts 'Added a new item!'
    when choices[3]
      puts('') # Add spacing
      print_bibliography(bibarray)
    when choices[4]
      puts("G'bye!")
      done = true
    end
    break if done
  end
end

main
