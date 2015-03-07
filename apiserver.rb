#!/usr/bin/env ruby
require 'sinatra'
require 'json'
require 'securerandom' #for uuid generation
require_relative 'sign.rb'

set :bind, '0.0.0.0'
set :port, '8080'

conf_file = File.read("./sign.conf") #this can be dangerous if the file gets too big but our conf file should always be really small
conf_json = JSON.parse conf_file

sign = SignHandler.new(conf_json["serialDevice"])

get '/' do
	File.read('./README.md')
end

post '/message/new' do #write a new message to the sign
	newid = SecureRandom.uuid
	request.body.rewind #I'm not sure what this does but sinatra docs say to do it
	data = JSON.parse request.body.read
	#I'm not sure if the line below is elegant or hackey
	sign.add(newid,data['message'],(data['color'].to_sym if data.has_key?('color')),(data['transition'].to_sym if data.has_key?('transition')))
	data[:uuid] = newid
	data.to_json
end

delete '/message/:uuid' do |id| #delete message [uuid]
	sign.delete(id)
end

post '/message/:uuid' do |id| #change message [uuid]
	request.body.rewind #ditto above
	data = JSON.parse request.body.read
	#the "add" method from the sign class doesn't care if you're adding a new message or updating an existing one
	sign.add(id,data['message'],(data['color'].to_sym if data.has_key?('color')),(data['transition'].to_sym if data.has_key?('transition')))
	data[:uuid] = id
	data.to_json
end

get '/message/:uuid' do |id| #I'm not sure if this is useful or why anyone would need it but I'm including it anyway just in case
	data = Hash.new
	data['message'] = sign.messages[id][0]
	data['color'] = sign.messages[id][1]
	data['transition'] = sign.messages[id][2]
	data.to_json
end

