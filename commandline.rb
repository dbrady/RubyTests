#!/usr/bin/env ruby

count=0
ARGV.each do |arg|
  puts "#{count}: #{arg}"
  count += 1
end

