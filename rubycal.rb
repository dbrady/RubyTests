#!/bin/env ruby
# == Synopsis
#
# getopt: shows the month and year for today, or based on command line
#
# == Usage
#
# getopt [OPTION]  (or 'ruby getopt.rb [OPTION]')
#
# -h, --help:
#    show help
#
# -m x, --month x:
#    use x as the month number to show
#
# -y x, --year x:
#    use x as the year number to show

require 'getoptlong'
require 'rdoc/usage'

class CalendarPrinter
  attr :year
  attr :month
  attr :todayYear
  attr :todayMonth

  #setup defaults
  def initialize(year, month)
    @year = year
    @month = month
    
    #these will be stored to compare the date being printed with 'today' such that 'today'
    #can be marked as such in the printed calendar
    t = Time.new
    @todayYear = t.year
    @todayMonth = t.month
    @todayDay = t.day
  end
  
  def printCalendar
    #print the top dashed line
    print "+"
    34.times do print "-" end
    print "+\n"
    
    #print the 'month, year' centered as the calendar title
    puts "|#{(Date::MONTHNAMES[@month] + ",  " + @year.to_s).center 34}|"
    printSeparatorLine
    
    #shortened names for days of the week
    printDayNames
    printSeparatorLine
    
    #print all the days in the given month
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
    #tracks how many days (or blank days) have already been printed for this calendar week
    daysThisRow = 0
    
    #print enough blank days so the first day of the month will be correctly positioned
    firstDayOfMonth.times do printBlankDay; daysThisRow += 1 end
    
    #how many days are in this month?
    daysInThisMonth = daysInMonth
    daysInThisMonth.times do | dayNumber |
      #as soon as we've printed 7 days, reset to the next line
      if daysThisRow == 7 
        print "|\n"
        printSeparatorLine
        daysThisRow = 0
      end
      printDay(dayNumber + 1)
      daysThisRow += 1
    end
    
    #print enough blank days at the end of the month to fill up the week
    while(daysThisRow < 7) do printBlankDay; daysThisRow += 1 end
    print "|\n"
  end

  def firstDayOfMonth
    Date.new(@year, @month, 1).wday
  end

end

def parseCommandLine
  opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--month', '-m', GetoptLong::OPTIONAL_ARGUMENT],
    ['--year', '-y', GetoptLong::OPTIONAL_ARGUMENT]
  )

  t = Time.new
  year = t.year
  month = t.month

  opts.each do |opt, arg|
    case opt
    when '--help'
      RDoc::usage
    when '--month'
      month = arg.to_i
    when '--year'
      year = arg.to_i
    end
  end  
  return year, month
end

year, month = parseCommandLine
cal = CalendarPrinter.new(year, month)
cal.printCalendar