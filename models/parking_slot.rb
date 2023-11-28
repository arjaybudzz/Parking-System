class ParkingSlot
  include Comparable

  VALID_SIZES = /\A(Small)\z|\A(Medium)\z|\A(Large)\z/i.freeze
  SIZES = { Small: -1, Medium: 0, Large: 1 }.freeze

  attr_reader :size, :is_empty

  def initialize(size: nil, is_empty: true)
    @size = size
    @is_empty = is_empty
  end

  def size=(value)
    raise InvalidInputError, 'Please enter a valid input' unless value.instance_of?(String)

    raise InvalidSizeError, 'Invalid parking slot size.' unless value.capitalize =~ VALID_SIZES

    @size = value.capitalize
  end

  def vacant?
    return is_empty
  end

  def vacate
    @is_empty = true
    return is_empty
  end

  def occupy
    @is_empty = false
    return is_empty
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
