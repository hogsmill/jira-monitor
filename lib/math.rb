
def average(arr)
  arr.sum / arr.size.to_f
end

def standardDeviation(array)
  m = average(array)
  variance = array.inject(0) { |variance, x| variance += (x - m) ** 2 }
  Math.sqrt(variance/(array.size-1))
end
