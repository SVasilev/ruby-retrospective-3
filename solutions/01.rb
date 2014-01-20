class Integer
  def first_divisor
    (2..self).each { |i| return i if remainder(i).zero? }
  end

  def prime?
    ((2...self).none? { |i| remainder(i).zero? } and self > 1)
  end

  def prime_factors
    result_array, self_value = [], abs
    until self_value == 1
      result_array << self_value.first_divisor
      self_value /= self_value.first_divisor
    end
    result_array
  end

  def harmonic
    result = Rational(0, 1)
    (1..self).each { |i| result += Rational(1, i) }
    result
  end

  def digits
    abs.to_s.chars.map { |element| element.to_i }
  end
end

class Array
  def frequencies
    result_hash = {}
    each { |i| result_hash[i] = count(i) }
    result_hash
  end

  def average
    return if empty?
    sum = 0.0
    each { |i| sum += i }
    sum / length
  end

  def drop_every(n)
    result = []
    each_index { |i| result << self[i] unless (i + 1).remainder(n).zero? }
    result
  end

  def combine_with(other)
    small  = length <= other.length ? self : other
    large  = length <= other.length ? other : self
    result = []

    (0...small.length).each { |i| result << self[i] << other[i] }
    (small.length..large.length - 1).each { |i| result << large[i] }
    result
  end
end



p 123.to_s