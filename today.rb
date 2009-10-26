#!/bin/env ruby

def days_in_month(month, year)
  (Date.new(year, 12, 31) << (12-month)).day
end

def first_day_of_month(month, year)
  days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  day = days[Date.new(year, month, 1).wday]
end

def info_for_day(day, month, year)
  d = Date.new(year, month, day)
  puts "\tDay of the week: #{d.wday}"
  puts "\tDay of the year: #{d.yday}"
  puts "\tDays in this month: #{days_in_month(month, year)}"
  puts "\tFirst day of the month: #{first_day_of_month(month, year)}"
end

t = Time.new
puts "Today is #{t}"
info_for_day(t.day, t.month, t.year)