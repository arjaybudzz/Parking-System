class Vehicle
  include Comparable

  VALID_SIZES = /\A(Small)\z|\A(Medium)\z|\A(Large)\z/i.freeze
  SIZES = { 'Small' => -1, 'Medium' => 0, 'Large' => 1 }.freeze

  attr_reader :size

  def size=(value)
    raise InvalidInputError, 'Please enter a valid input.' unless value.instance_of?(String)
    raise InvalidSizeError, 'Invalid vehicle size.' unless value.capitalize =~ VALID_SIZES

    @size = value.capitalize
  end

  def to_s
    size
  end

  def >(other)
    return SIZES[size] > SIZES[other.size]
  end

  def <(other)
    return SIZES[size] < SIZES[other.size]
  end

  def ==(other)
    return SIZES[size] == SIZES[other.size]
  end

  def >=(other)
    return self > other || self == other
  end

  def <=(other)
    return self < other || self == other
  end
end
