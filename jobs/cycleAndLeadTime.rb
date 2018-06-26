
require 'mongo'
require_relative '../lib/config'
require_relative '../lib/strings'
require_relative '../lib/math'
require_relative '../lib/datetime'
require_relative '../lib/db'

class CycleAndLeadTimes
  def initialize
    @db = dbConnect()
  end

  def getMonthlyData(team = "")
    issues = @db[:issues]

    if (team.empty?)
      data = issues.find({"status": "Closed"}).sort({"resDate": 1})
    else
      data = issues.find({"projectName": team, "status": "Closed"}).sort({"resDate": 1})
    end

    results = { :cycleTime => {}, :leadTime => {} }
    data.each do |issue|
      resMonth = monthStamp(issue[:resDate])
      if (!results[:leadTime].key?(resMonth))
        results[:leadTime][resMonth] = []
        results[:cycleTime][resMonth] = []
      end
      results[:leadTime][resMonth] << issue[:leadTime]
      results[:cycleTime][resMonth] << issue[:cycleTime]
    end

    leadTimes = []
    cycleTimes = []
    if (!results[:leadTime])
      results[:leadTime].keys.each do |month|
        leadTimes << { "x" => month, "y" => average(results[:leadTime][month]) }
        cycleTimes << { "x" => month, "y" => average(results[:cycleTime][month]) }
      end
    end
    results[:leadTime] = leadTimes
    results[:cycleTime] = cycleTimes

    results
  end

  def getSummaryData(team = "")
    summary = @db[:summary]

    if (team.empty?)
      data = summary.find().sort({"date": 1})
    else
      data = summary.find("projectName": team).sort({"date": 1})
    end

    results = { :cycleTime => [], :leadTime => [] }
    data.each do |stat|
      results[:cycleTime] << {"x" => timeStamp(stat[:date]), "y" => stat[:cycleTime].to_i}
      results[:leadTime] << {"x" => timeStamp(stat[:date]), "y" => stat[:leadTime].to_i}
    end
    results
  end

  def sendSeriesData(results, id, type = "")
    if (!results[:leadTime].empty? && !results[:cycleTime].empty?)
      seriesData = [
        { name: "Lead Time", color: "#fff", data: results[:leadTime] },
        { name: "Cycle Time", color: "#ff8154", data: results[:cycleTime] }
      ]
      send_event(id,
        series: seriesData,
        prefix_lead: "#{type} Lead Time: ",
        current_lead: sprintf("%.2f", results[:leadTime].last()["y"].to_s),
        prefix_cycle: "#{type} Cycle Time: ",
        current_cycle: sprintf("%.2f", results[:cycleTime].last()["y"].to_s))
      end
  end

  def getStats(team = "")
    issues = @db[:issues]

    if (team.empty?)
      data = issues.find()
    else
      data = issues.find("projectName": team)
    end
    leadTime = []
    cycleTime = []
    data.each do |stat|
      if (stat[:cycleTime] > 0)
        cycleTime << stat[:cycleTime].to_int
      end

      if (stat[:leadTime] > 0)
        leadTime << stat[:leadTime].to_int
      end
    end

    cycleTimeMean = average(cycleTime)
    leadTimeMean = average(leadTime)
    {
      cycleMean: sprintf("%.2f", cycleTimeMean),
      cycleStdDevMin: sprintf("%d", cycleTimeMean - standardDeviation(cycleTime)),
      cycle2StdDevMin: sprintf("%d", cycleTimeMean - 2 * standardDeviation(cycleTime)),
      cycleStdDevMax: sprintf("%d", cycleTimeMean + standardDeviation(cycleTime)),
      cycle2StdDevMax: sprintf("%d", cycleTimeMean + 2 * standardDeviation(cycleTime)),
      leadMean: sprintf("%d", leadTimeMean),
      leadStdDevMin: sprintf("%d", leadTimeMean - standardDeviation(leadTime)),
      lead2StdDevMin: sprintf("%d", leadTimeMean - 2 * standardDeviation(leadTime)),
      leadStdDevMax: sprintf("%d", leadTimeMean + standardDeviation(leadTime)),
      lead2StdDevMax: sprintf("%d", leadTimeMean + 2 * standardDeviation(leadTime))
    }

  end

end

times = CycleAndLeadTimes.new()

SCHEDULER.every "5m", first_in: 0 do |job|

  results = times.getSummaryData()
  times.sendSeriesData(results, 'leadandcycletime')

  $config[:projects].each do |project|
    results = times.getSummaryData(project)
    times.sendSeriesData(results, "leadandcycletime-#{id(project)}")
  end

  monthly = times.getMonthlyData()
  times.sendSeriesData(monthly, 'monthlyleadandcycletime', "Monthly")

  $config[:projects].each do |project|
    results = times.getMonthlyData(project)
    times.sendSeriesData(results, "monthlyleadandcycletime-#{id(project)}", "Monthly")
  end

  stats = times.getStats()
  send_event("stats", stats)

end
