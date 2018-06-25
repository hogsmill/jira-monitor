
def average(arr)
  ave = arr.inject{ |sum, el| sum + el }.to_f / arr.size
end
