
def timeStamp(date)
  date = date.split("-")
  Time.utc(date[0], date[1], date[2]).to_i
end

def monthStamp(date)
  date = date.split("-")
  Time.utc(date[0], date[1], 1).to_i
end

def startOfToday()
  date = Time.new()
  Time.utc(date.year, date.month, date.day, 0, 0, 0)
end

def endOfToday()
  date = Time.new()
  Time.utc(date.year, date.month, date.day, 23, 59, 59)
end

def beforeOrOnToday(date)
  date = date.split("-")
  Time.utc(date[0], date[1], date[2]) <= endOfToday()
end

def onOrAfterToday(date)
  date = date.split("-")
  Time.utc(date[0], date[1], date[2]) >= startOfToday()
end
