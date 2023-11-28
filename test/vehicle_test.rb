require 'minitest/autorun'
require 'vehicle'
require_relative './../error/invalid_size'

class VehicleTest < Minitest::Test
  def setup
    @vehicle = Vehicle.new
  end

  def test_size
    @vehicle.size = 'sMall'
    assert_match(Vehicle::VALID_SIZES, @vehicle.size)
  end

  def test_invalid_input
    assert_raises(InvalidSizeError, 'Invalid vehicle size.') do
      @vehicle.size = 'invalid'
    end
  end
end
