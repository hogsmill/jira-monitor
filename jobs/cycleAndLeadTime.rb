
require 'mongo'

$config = {
  :mongo => {
    :ip => '127.0.0.1',
    :port => 27017,
    :database => 'test'
  }
}

def dbConnect
  client = Mongo::Client.new([ "#{$config[:mongo][:ip]}:#{$config[:mongo][:port]}" ],
    :database => $config[:mongo][:database])
  client
end

def timeStamp(date)
  date = date.split("-")
  Time.utc(date[0], date[1], date[2]).to_i
end

def getData(db)
  summary = db[:summary]

  results = {
    :cycleTime => [],
    :leadTime => []
  }
  summary.find().sort({"date": 1}).each do |stat|
    results[:cycleTime] << {"x" => timeStamp(stat[:date]), "y" => stat[:cycleTime].to_i}
    results[:leadTime] << {"x" => timeStamp(stat[:date]), "y" => stat[:leadTime].to_i}
  end
  results
end

db = dbConnect()

SCHEDULER.every "10s", first_in: 0 do |job|

  results = getData(db)

  leadAndCycleTimes = [
    {
        name: "Lead Time",
        color: "#fff",
        data: results[:leadTime]
    },
    {
        name: "Cycle Time",
        color: "#ff8154",
        data: results[:cycleTime]
    }
  ]
  send_event('leadandcycletime',
    series: leadAndCycleTimes,
    prefix_lead: "Lead Time: ",
    current_lead: results[:leadTime].last()["y"],
    prefix_cycle: "Cycle Time: ",
    current_cycle: results[:cycleTime].last()["y"])

  send_event('cycletime', points: results[:cycleTime])
  send_event('leadtime', points: results[:leadTime])

end
