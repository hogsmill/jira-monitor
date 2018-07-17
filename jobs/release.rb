
require_relative '../lib/db'

class Release
  def initialize
    @db = dbConnect()
  end

  def getNextRelease()
    releases = @db[:releases]

    release = releases.find({"current": true}).first

    {
      releaseNumber: release["number"],
      team: release["team"],
      releaseDate: release["date"],
      codeCutOff: release["codeCutOff"],
      branchCut: release["branchCut"],
      smokepackPassed: release["smokepackPassed"],
      systemTestsPassed: release["systemTestsPassed"],
      regressionTestsPassed: release["regressionTestsPassed"],
      go: release["go"],
      released: release["released"],
      retro: release["retro"]
    }
  end
end

releases = Release.new()

SCHEDULER.every "5m", first_in: 0 do |job|

  release = releases.getNextRelease()
  send_event('release', release)
end
