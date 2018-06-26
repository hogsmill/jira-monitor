
require 'mongo'
require_relative '../lib/config'
require_relative '../lib/db'

class OutBoard

  def initialize
    @db = dbConnect()
    @icons = {
      'In' => { :icon => 'fas fa-star', :status => 'in' },
      'WFH' => { :icon => 'fas fa-home', :status => 'out' },
      'Vacation' => { :icon => 'fas fa-plane', :status => 'out' },
      'Training' => { :icon => 'fas fa-book-open', :status => 'out' },
      'Conference' => { :icon => 'fas fa-school', :status => 'out' },
      'Out' => { :icon => 'fas fa-remove', :status => 'out' }
    }
  end

  def current(member)
    beforeOrOnToday(member[:start]) && onOrAfterToday(member[:end])
  end

  def getWhereabouts(member)
    whereabouts = @db[:whereabouts]

    status = { :name => member[:name], :status => "In", :icon => @icons['In'][:icon] }
    whereabouts.find({"name": member[:name]}).each do |memberWhereabouts|
      if (self.current(memberWhereabouts))
        memberStatus = memberWhereabouts[:status]
        status[:status] = @icons[memberStatus][:status]
        status[:icon] = @icons[memberStatus][:icon]
      end
    end

    status
  end

  def getTeamWhereabouts(team)
    teams = @db[:teams]

    values = []
    teams.find({"team": team}).each do |member|
      values << self.getWhereabouts(member)
    end

    values
  end

end

outboard = OutBoard.new()

SCHEDULER.every '1m', :first_in => 0 do |job|

  values = outboard.getTeamWhereabouts("Onboard")

  send_event('outboard', :values => values)

end
