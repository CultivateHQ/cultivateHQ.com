#!/usr/bin/env ruby

puts 'Tell me your title'
title = gets.strip

puts 'Who the hell are you?'
author = gets.strip

puts 'Ok, give me a brief description'
description = gets.strip

date = Time.now.strftime('%Y-%m-%d')
file_suffix = title.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9-]/, '')

file = "source/posts/#{date}-#{file_suffix}.html.md"

p [title, file_suffix, date, file]

File.open(file, 'w') do |f|
  f.puts '---'
  f.puts "author: #{author}"
  f.puts "title: #{title}"
  f.puts "description: #{description}"
  f.puts '---'
  f.puts
end

editor = ENV['EDITOR']

exec("#{editor} #{file}") if editor
