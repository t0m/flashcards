require 'rubygems'
gem 'sinatra'
require 'flashcards'
set :run, false
set :environment, :production
run Sinatra::Application
