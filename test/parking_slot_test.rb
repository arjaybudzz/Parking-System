require 'minitest/autorun'
require 'parking_slot'
require_relative './../error/invalid_size'

class ParkingSlotTest < Minitest::Test
  def setup
    @parking_slot = ParkingSlot.new
  end

  def test_size_input
    @parking_slot.size = 'sMALl'
    assert_match(ParkingSlot::VALID_SIZES, @parking_slot.size)
  end

  def test_invalid_input
    assert_raises(InvalidSizeError, 'Invalid parking slot size.') do
      @parking_slot.size = 'invalid'
    end

    assert_raises(InvalidInputError, 'Please enter a valid input') do
      @parking_slot.size = 1 # type integer instead of type string
    end
  end

  def test_vacant_function
    assert_equal(@parking_slot.vacant?, true)
  end

  def test_occupy_function
    @parking_slot.occupy
    assert_equal(@parking_slot.vacant?, false)
  end
end
