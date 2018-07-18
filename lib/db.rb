
require 'mongo'
require_relative '../lib/config'

def dbConnect(uri = '')

  if (!uri.empty?)
    puts "Connecting to #{uri}"
    client = Mongo::Client.new(uri)
  else
    ip = $config[:mongo][:ip]
    port = $config[:mongo][:port]
    database = $config[:mongo][:database]
    puts "Connecting to #{ip}:#{port}, #{database}"

    client = Mongo::Client.new([ "#{ip}:#{port}" ], :database => database)
  end

  client
end
