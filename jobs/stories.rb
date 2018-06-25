
require 'mongo'
require_relative '../lib/config'
require_relative '../lib/datetime'
require_relative '../lib/strings'
require_relative '../lib/db'

class Stories

  def initialize
    @db = dbConnect()
  end

  def getStories(team = "")
    issues = @db[:issues]

    results = { :created => {}, :closed => {} }

    if (team.empty?)
      stories = issues.find().sort({"created": 1})
    else
      stories = issues.find({"projectName": team}).sort({"created": 1})
    end

    stories.each do |issue|

      createdMonth = monthStamp(issue[:created])
      if (!results[:created].key?(createdMonth))
        results[:created][createdMonth] = 0
      end
      results[:created][createdMonth] = results[:created][createdMonth] + 1

      if (issue[:status] == "Closed")
        closedMonth = monthStamp(issue[:resDate])
        if (!results[:closed].key?(closedMonth))
          results[:closed][closedMonth] = 0
        end
        results[:closed][closedMonth] = results[:closed][closedMonth] + 1
      end
    end

    created = []
    closed = []
    results[:created].keys.each do |month|
      created << { "x" => month, "y" => results[:created][month].nil? ? 0 : results[:created][month] }
      closed << { "x" => month, "y" => results[:closed][month].nil? ? 0 : results[:closed][month] }
    end
    results[:created] = created
    results[:closed] = closed

    results
  end

  def sendSeriesData(results, id)
    if (!results[:created].empty? && !results[:closed].empty?)
      seriesData = [
        { name: "Stories Created", color: "#fff", data: results[:created] },
        { name: "Stories Closed", color: "#ff8154", data: results[:closed] }
      ]
      send_event(id,
        series: seriesData,
        prefix_lead: "Stories Created: ",
        current_lead: sprintf("%d", results[:created].last()["y"].to_s),
        prefix_cycle: "Stories Closed: ",
        current_cycle: sprintf("%d", results[:closed].last()["y"].to_s))
      end
  end

end

story = Stories.new()

SCHEDULER.every "5m", first_in: 0 do |job|

  stories = story.getStories()
  story.sendSeriesData(stories, 'stories')

  $config[:projects].each do |team|
    stories = story.getStories(team)
    story.sendSeriesData(stories, "stories-#{id(team)}")
  end

end
