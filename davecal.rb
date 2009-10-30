#!/usr/bin/env ruby


today = Date.today


month = today.month
day = 1
dow = Date.new(today.year, today.month, 1).wday

def format_bar(ticks=true)
  if ticks
    "+----" * 7 + "+"
  else
    "+" + '-' * 34 + "+"
  end
end

def format_title(title)
  len = 34
  ws1 = ((len-title.length)/2) + title.length
  ws2 = len - ws1
  
  "|%#{ws1}s%#{ws2}s|" % [title, '']
end

def format_row(row)
  "|#{(0..6).map {|i| ' %02s ' % row[i]} * '|'}|"
end

title = "#{Date::MONTHNAMES[month]} #{today.year}"

dates = [nil] * (dow-1) + (1..31).to_a


puts format_bar(false)
puts format_title(title)
puts format_bar
puts format_row(%w{Su Mo Tu We Th Fr Sa})
puts format_bar
dates.each_slice(7) do |row|
  puts format_row(row)
end
puts format_bar
