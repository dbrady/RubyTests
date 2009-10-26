#!/bin/env ruby

class CalendarPrinter
  attr :year
  attr :month
  attr :todayYear
  attr :todayMonth

  #setup defaults
  def initialize(year, month)
    @year = year
    @month = month
    t = Time.new
    @todayYear = t.year
    @todayMonth = t.month
    @todayDay = t.day
  end
  
  def printCalendar
    print "+"
    34.times do print "-" end
    print "+\n"
    puts "|#{(Date::MONTHNAMES[@month] + ",  " + @year.to_s).center 34}|"
    printSeparatorLine
    printDayNames
    printSeparatorLine
    printMonthDays
    printSeparatorLine
  end
  
  private
  def printSeparatorLine
    7.times do print "+----" end
    print "+\n"
  end

  def printDayNames
    Date::DAYNAMES.each do |i|
      print "| ", i[0..1], " "
    end
    puts "|"
  end
  
  def printBlankDay
    print "|    "
  end

  def printDay(day)
    isToday = (day == @todayDay && @year == @todayYear && @month == @todayMonth) ? true : false
    spacerCharLeft = isToday ? "[" : " "
    spacerCharRight = isToday ? "]" : " "
    day = " " + day.to_s if(day < 10)
    print "|#{spacerCharLeft}", day, "#{spacerCharRight}"
  end
  
  def daysInMonth
    (Date.new(@year, 12, 31) << (12-@month)).day
  end

  def printMonthDays
    daysThisRow = 0
    firstDayOfMonth.times do printBlankDay; daysThisRow += 1 end
    daysInThisMonth = daysInMonth
    daysInThisMonth.times do | dayNumber |
      if daysThisRow == 7 
        print "|\n"
        printSeparatorLine
        daysThisRow = 0
      end
      printDay(dayNumber + 1)
      daysThisRow += 1
    end
    while(daysThisRow < 7) do printBlankDay; daysThisRow += 1 end
    print "|\n"
  end

  def firstDayOfMonth
    Date.new(@year, @month, 1).wday
  end

end

def getCommandLineParametersOrDefaults
  t = Time.new
  month = t.month
  year = t.year
  ARGV.each do |arg|
    if(arg.start_with? "-y")
      tmp = arg[2..(arg.length - 1)]
      year = tmp.to_i
    end
    if(arg.start_with? "-m")
      tmp = arg[2..(arg.length - 1)]
      month = tmp.to_i
    end
  end
  return year, month
end

def isHelp?
  ARGV.each do |arg|
    return true if (arg.start_with? "-h") || (arg.start_with? "--h")
  end
  return false
end

def showHelpAndExit
  puts ""
  puts "RubyCal"
  puts ""
  puts "Usage:"
  puts ""
  puts "\truby RubyCal.rb"
  puts "\t(show a calendar for the current month)"
  puts ""
  puts "\truby RubyCal.rb [-yyear] [-mmonth]"
  puts "\t(show a calendar for the specified year and month (i.e.: '-y2009 -m10'))"
  puts ""
  puts "\truby RubyCal.rb -h"
  puts "\t(show this help information)"
  puts ""
  exit
end

showHelpAndExit if isHelp?
year, month = getCommandLineParametersOrDefaults
cal = CalendarPrinter.new(year, month)
cal.printCalendar