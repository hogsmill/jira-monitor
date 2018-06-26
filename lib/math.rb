
def average(arr)
  total = 0
  arr.each do |elem|
    total = total + elem.to_f
  end
  total
  arr.size == 0 ? 0 : total / arr.size.to_f
end

def standardDeviation(array)
  m = average(array)
  variance = array.inject(0) { |variance, x| variance += (x - m) ** 2 }
  Math.sqrt(variance/(array.size-1))
end
