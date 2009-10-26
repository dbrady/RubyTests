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

# ----------------------------------------------------------------------
# dbrady 2009-10-26: General Rubification:
# 
# - Firstly: Look at Ruport, the Ruby reporting gem. You give it a
#   hash and it gives you a table automagically. This doesn't give you
#   the practice of building these tables yourself, so we'll continue
#   as though Ruport did not exist, but for future reference, it is
#   awesome.
# 
# - In general, favor returning strings rather than touching the
#   display. In the short term this makes your code more testable. In
#   the long term in makes your code more reusable--I could use this
#   in an IRC bot or other socket-based program, for example, but
#   shoving the strings over the wire instead of to the console.
# 
# - This has an implication for the external driver, as well. You
#   would want to say "puts calendar.getCalendar" or similar. But Ruby
#   already has an idiomatic method for this: to_s. By defining to_s,
#   your driver code would now read: "puts calendar".
# 
# - Most of my output/formatting suggestions center around
#   understanding puts vs. print, string formatting and array joins:
# 
# - never print "\n". That's puts' job.
# 
# - String.* is defined as repeat.
# 
# - You can join an array with .join: [1,2,3].join('|') => 1|2|3. This
#   is overloaded to Array.* as well: [1,2,3] * '/' => 1/2/3.

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
  
  # dbrady 2009-10-26: Favor puts obj.to_s over obj.printMe.
  # dbrady 2009-10-26: Also favor returning strings over putsing to the display. It's more testable.
  def to_s
    printCalendar
  end
  
  def printCalendar
    #print the top dashed line
    # dbrady 2009-10-26: puts '+' + '-' * 34 + '+'
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
    # dbrady 2009-10-26: puts "+----" * 7 + "+"
    # dbrady 2009-10-26: puts "+" + "+----" * 7
    # dbrady 2009-10-26: puts((['+'] * 8).join('----')
    # dbrady 2009-10-26: puts((['+'] * 8) * '----')
    7.times do print "+----" end
    print "+\n"
  end

  def printDayNames
    # dbrady 2009-10-26: 
    # Favor expressions over iteration:
    # 
    # puts "|" + Date::DAYNAMES * "|" + "|"
    # => |Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|
    # 
    # Not quite what we want. Use a map to shorten the DAYNAMES to
    # 2-letters:
    #
    # puts "|" + Date::DAYNAMES.map{|d| d[0..1]} * '|' + "|"
    # => |Su|Mo|Tu|We|Th|Fr|Sa|
    # 
    # Still not quite right. Need padding. Not a problem, we can add
    # that in the map itself:
    # 
    # puts "|" + Date::DAYNAMES.map{|d| " %s " % d[0..1]} * '|' + "|"
    # => | Su | Mo | Tu | We | Th | Fr | Sa |
    # 
    # There we go. We could also have used interpolation instead of
    # the % operator:
    # 
    # puts "|" + Date::DAYNAMES.map{|d| " #{d[0..1]} "} * '|' + "|"
    # => | Su | Mo | Tu | We | Th | Fr | Sa |
    Date::DAYNAMES.each do |i|
      print "| ", i[0..1], " "
    end
    puts "|"
  end
  
  # dbrady 2009-10-26: We'll use some string formatting tricks below,
  # but for now, favor printDay(nil) over a special function.
  def printBlankDay
    print "|    "
  end

  # dbrady 2009-10-26: You can replace this whole method with:
  # print "|%02d" % day
  # 
  # Except! If we allow day to be nil (to print blank spaces), it will
  # print zeroes--not what we wanted. Not a problem, however: integers
  # cast to strings print normally, while nil cast to a string becomes
  # blank. So we can combine printDay and printBlankDay like so:
  # 
  # def printDay(day=nil)
  #   print "| %02s " % day
  # end
  
  def printDay(day)
    isToday = (day == @todayDay && @year == @todayYear && @month == @todayMonth) ? true : false
    spacerCharLeft = isToday ? "[" : " "
    spacerCharRight = isToday ? "]" : " "
    day = " " + day.to_s if(day < 10)
    print "|#{spacerCharLeft}", day, "#{spacerCharRight}"
  end
  
  # dbrady 2009-10-26: Interesting trick! I did not know this one.
  # Ruby dates work like Ruby arrays, however; I use this method:
  # 
  # Date.new(@year, @month, -1).day
  # 
  # In PHP, I use something like Date.new(@year, @month+1, 1) - 1, but
  # you can't do this in Ruby. Month 13 will raise an exception. (PHP,
  # OTOH, will cheerfully let you select the 43rd day of Jancember.)
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
