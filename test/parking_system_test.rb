require 'minitest/autorun'
require 'parking_system'
require_relative './../error/invalid_size'
require_relative './../error/invalid_input'

class ParkingSystemTest < Minitest::Test
  def setup
    @parking_system = ParkingSystem.new
  end

  def test_add_entry_point
    entry_point = 'D'
    @parking_system.add_entry_point(entry_point)
    assert_includes(@parking_system.parking_slots, entry_point)
  end

  def test_remove_entry_point
    entry_point = 'D'
    @parking_system.add_entry_point(entry_point)
    @parking_system.remove_entry_point(entry_point)
    assert_equal(@parking_system.parking_slots.key?(entry_point), false)
  end

  def test_invalid_entry_point_removal
    invalid_vehicle_input = 'small' # type string instead of type vehicle
    assert_raises(InvalidInputError) do
      @parking_system.remove_entry_point('A')
      @parking_system.park(invalid_vehicle_input)
    end
  end

  def test_add_parking_slot
    parking_slot_size = 'small'
    entry_point = 'A'

    @parking_system.add_parking_slot(entry_point, parking_slot_size)
    assert_equal(@parking_system.parking_slots[entry_point].size, 1)
  end

=begin
  def test_check_vacancies_if_vehicle_size_is_equal_to_parking_slot_size
    entry_point = 'A'
    parking_slot_size = 'small'
    vehicle_sample = Vehicle.new
    vehicle_sample.size = 'small'

    num_slots = 5
    start = 1

    while start <= num_slots
      @parking_system.add_parking_slot(entry_point, parking_slot_size)
      start += 1
    end

    assert_equal(@parking_system.allocate_vacancy(entry_point, vehicle_sample), { available: @parking_system.parking_slots[entry_point].first, slot_number: 1, entry_point: entry_point })
  end
=end

  def test_park_function
    vehicle = Vehicle.new
    entry_point = 'A'
    vehicle.size = 'small'
    parking_slot_size = 'Small'
    @parking_system.add_parking_slot(entry_point, parking_slot_size)

    assert(@parking_system.park(vehicle))
  end
=begin
  def test_calculate_fee
    vehicle = Vehicle.new
    entry_point = 'A'
    vehicle.size = 'small'
    parking_slot_size = 'Small'

    @parking_system.add_parking_slot(entry_point, parking_slot_size)
    parking_slot = @parking_system.parking_slots[entry_point].first[:parking_slot]
    @parking_system.departing_time = Time.now + 86_400

    assert_equal(@parking_system.calculate_fee(parking_slot), 5_000)
  end
=end

  def test_unpark_function
    vehicle = Vehicle.new
    entry_point = 'A'
    vehicle.size = 'small'
    parking_slot_size = 'Small'

    @parking_system.add_parking_slot(entry_point, parking_slot_size)
    @parking_system.park(vehicle)
    @parking_system.departing_time = Time.now + 86_400
    assert_equal(@parking_system.unpark(vehicle, entry_point, 1), 5_000)
  end

  def test_leave_function
    vehicle = Vehicle.new
    entry_point = 'A'
    vehicle.size = 'small'
    parking_slot_size = 'Small'

    @parking_system.add_parking_slot(entry_point, parking_slot_size)
    @parking_system.park(vehicle)
    @parking_system.departing_time = Time.now + 86_400
    @parking_system.temporary_leave(vehicle, entry_point, 1, Time.now + 3_600, Time.now)
    assert_equal(@parking_system.calculate_fee(@parking_system.parking_slots[entry_point].first[:parking_slot]), 5_000)
  end
end
