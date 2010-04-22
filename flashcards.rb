# coding: utf-8

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
  property :correct,    Integer, :default => 0
  property :created_at, DateTime

  has n, :categories, :through => Resource, :constraint => :destroy

  def self.random(categories = [])
    if categories.empty?
      Flashcard.all(:correct.lte => 5).sort_by{rand}.first
    else
      Category.all(:name => categories, :correct.lte => 5).flashcards.sort_by{rand}.first
    end
  end
end

class Category
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String

  has n, :flashcards, :through => Resource, :constraint => :destroy
end

DataMapper.auto_upgrade!
Flashcard.create(:characters => '中文', :pinyin => 'zhongwen', :english => 'chinese') if Flashcard.count == 0

get "/correct/:id" do
  flashcard = Flashcard.get(params[:id])
  flashcard.correct += 1
  flashcard.save
  get_flashcard(params)


  if request.xhr? && !@flashcard.nil?
    content_type 'text/json' 
    @flashcard.to_json 
  else  
    erb :index
  end
end

get "/" do
  get_flashcard(params)

  if request.xhr? && !@flashcard.nil?
    content_type 'text/json' 
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

post "/category" do
  category = Category.new(params)
  if category.save
    @categories = Category.all
    erb :categories
  end
end

post "/reset" do
  repository(:default).adapter.execute('update flashcards set correct = 0')
  get_flashcard(params)
  erb :index, :layout => false
end

private

def get_flashcard(params)
  if params[:categories]
    @flashcard = Flashcard.random(params[:categories])
  else
    @flashcard = Flashcard.random
  end

  @categories = Category.all
end
