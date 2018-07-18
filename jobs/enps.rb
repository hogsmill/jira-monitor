
require_relative '../lib/config'
require_relative '../lib/datetime'
require_relative '../lib/strings'
require_relative '../lib/db'

class Enps
  def initialize
    @db = dbConnect('mongodb://hogsmill:h0gsmill@ds161620.mlab.com:61620/nps')
  end

  def getScores(team = '')
    enps = @db[:nps]

    scores = enps.find().sort({"date": 1})

    results = {
      :all => {}
    }
    scores.each do |score|
      date = score[:date].to_s.split(" ")[0]
      team = score[:team]
      dateScores = score[:nps]
      if (!results.key?(team))
        results[team] = []
      end
      if (!results[:all].key?(date))
        results[:all][date] = dateScores
      else
        results[:all][date] = results[:all][date] + dateScores
      end
      results[team] << { "x" => timeStamp(date), "y" => average(dateScores) }
    end
    results[:overall] = []
    results[:all].keys.each do |date|
      scores = average(results[:all][date])
      results[:overall] << { "x" => timeStamp(date), "y" => scores }
    end
    results.delete(:all)
    results
  end
end

enps = Enps.new()

SCHEDULER.every '5m', :first_in => 0 do |job|

  scores = enps.getScores()

  send_event("enps", {
    current_value: sprintf("%.1f", scores[:overall].last()["y"].to_s),
    prefix: "Overall eNPS: ",
    min: -10,
    max: 10,
    series: [{
      name: "Overall eNPS",
      color: "#fff",
      data: scores[:overall] }]
  })

  $config[:enpsTeams].keys.each do |team|

    if (team != "overall")
      teamName = $config[:enpsTeams][team]
      send_event("enps-#{team}", {
        current_value: sprintf("%.1f", scores[team].last()["y"].to_s),
        prefix: "#{teamName} eNPS: ",
        min: -10,
        max: 10,
        series: [{
          name: "#{teamName} eNPS",
          color: "#fff",
          data: scores[team] }]
      })
    end
  end
end
