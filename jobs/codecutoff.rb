
require 'date'

def timeString(t)
  daysString = t[:days] == 1 ? "day" : "days"
  hoursString = t[:hours] == 1 ? "hour" : "hours"
  minutesString = t[:minutes] == 1 ? "minute" : "minutes"

  hString = sprintf("%#o", t[:hours])
  mString = sprintf("%#o", t[:minutes])

  {
    time: "#{t[:days]}d, #{t[:hours]}:#{t[:minutes]}",
    info: "Code cut off in #{t[:days]} #{daysString}, #{hString} #{hoursString}, #{mString} #{minutesString}"
  }
end

def nextCodeCutOff

  date  = Date.parse("Monday")
  delta = date > Date.today ? 0 : 7
  date = date + delta
  if (Time.new(date.year, date.month, date.day).strftime('%U').to_i.even?)
    date = date + 7
  end
  secondsToGo = (Time.new(date.year, date.month, date.day, 12, 0, 0) - Time.new()).to_int
  daysToGo = secondsToGo / 86400.to_int
  hoursToGo = (secondsToGo - (daysToGo * 86400)) / 3600
  minutesToGo = (secondsToGo - (daysToGo * 86400) - (hoursToGo * 3600)) / 60
  {
    :seconds => secondsToGo,
    :days => daysToGo,
    :hours => hoursToGo,
    :minutes => minutesToGo
  }
end

SCHEDULER.every '10s', :first_in => 0 do |job|

  t = nextCodeCutOff()
  tStrings = timeString(t)

  send_event('codecutoff', {
    value: t[:seconds],
    timeString: tStrings[:time],
    moreinfo: tStrings[:info]
    })
end
