require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'dm-ar-finders'
require 'erb'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://localhost/flashcard?user=root&password=tom')

class Flashcard
  include DataMapper::Resource

  property :id,         Serial
  property :characters, String, :length => (1..50), :messages => {:length => 'You must enter at least one chinese word or phrase'}
  property :pinyin,     String, :length => (1..50), :messages => {:length => 'You must enter the pinyin for the chinese word or phrase'}
  property :english,    String, :length => (1..50), :messages => {:length => 'You must enter the english definition of the word or phrase'}
  property :created_at, DateTime

  has n, :categories, :through => Resource

  def self.random
    Flashcard.find_by_sql('select * from flashcards order by rand() limit 1').first
  end
end

class Category
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String

  has n, :flashcards, :through => Resource
end

DataMapper.auto_upgrade!

get "/" do
  @flashcard = Flashcard.random || Flashcard.new
  @categories = Category.all
  if request.xhr?
    @flashcard.to_json 
  else  
    erb :index
  end
end

post "/" do
  categories = Category.all(:name => params.delete('categories') || [])
  flashcard = Flashcard.new(params)
  flashcard.categories = categories

  if flashcard.save
    halt 200
  else
    flashcard.errors.full_messages.to_json
  end
end

post "/group" do
  category = Category.new(params)
  if category.save
    @categories = Category.all
    erb :categories
  end
end
