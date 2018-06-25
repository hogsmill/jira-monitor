
def dbConnect
  client = Mongo::Client.new([ "#{$config[:mongo][:ip]}:#{$config[:mongo][:port]}" ],
    :database => $config[:mongo][:database])
  client
end
