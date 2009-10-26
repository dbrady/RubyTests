#!/usr/bin/env ruby


today = Date.today


month = today.month
day = 1
dow = today.wday

puts Date::MONTHNAMES[month] + " " + today.year
puts "Su Mo Tu We Th Fr Sa"

puts "   " * dow

while 
end
