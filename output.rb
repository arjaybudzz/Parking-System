require_relative 'models/vehicle'
require_relative 'models/parking_slot'
require_relative 'models/parking_system'
require_relative 'error/invalid_size'
require_relative 'error/invalid_input'

begin
  # setup a parking system
  parking_system = ParkingSystem.new
  first_entry_point = 'A'
  second_entry_point = 'B'
  third_entry_point = 'C'
  small_parking_lot = 'Small'
  medium_parking_lot = 'Medium'
  large_parking_lot = 'Large'
  additional_entry_point = 'D'

  # add entry point
  # parking_system.add_entry_point(additional_entry_point)

  # remove entry point
  # parking_system.remove_entry_point(additional_entry_point)

  # add parking slots to 3 entry points


  number_of_parking_lots_per_entry_point = 10
  index = 0

  while index < number_of_parking_lots_per_entry_point
    parking_system.add_parking_slot(first_entry_point, small_parking_lot)
    index += 1
  end

  index = 0

  while index < number_of_parking_lots_per_entry_point
    parking_system.add_parking_slot(second_entry_point, medium_parking_lot)
    index += 1
  end

  index = 0

  while index < number_of_parking_lots_per_entry_point
    parking_system.add_parking_slot(third_entry_point, large_parking_lot)
    index += 1
  end


  # while index < number_of_parking_lots_per_entry_point
  #   parking_system.add_parking_slot(additional_entry_point, large_parking_lot)
  #   index += 1
  # end

  # Park a vehicle object

  small_vehicle = Vehicle.new
  small_vehicle.size = 'small'
  medium_vehicle = Vehicle.new
  medium_vehicle.size = 'medium'
  large_vehicle = Vehicle.new
  large_vehicle.size = 'large'

  # parking_system.park(small_vehicle)

  current = 0
  while current < number_of_parking_lots_per_entry_point
    parking_system.park(small_vehicle)
    current += 1
  end

  current = 0

  while current < number_of_parking_lots_per_entry_point
    parking_system.park(medium_vehicle)
    current += 1
  end

  parking_system.park(small_vehicle)

  # parking_system.remove_parking_slot(second_entry_point)

  # Unpark the vehicle object

  # parking_system.departing_time = Time.now + (3_600 * 1) # below 3 hours
  # parking_system.departing_time = Time.now + (3_600 * 5) # above 3 hours but less than 24
  # parking_system.departing_time = Time.now + (3_600 * 24) # 1 day after
  # parking_system.departing_time = Time.now + (3_600 * 26) # more than 1 day after and the excess time is below 3 hours
  # parking_system.departing_time = Time.now + (3_600 * 30) # more than 1 day after and the excess time is above 3 hours

  # parking_system.unpark(small_vehicle, third_entry_point, 1)

  # A vehicle leaves temporarily
  # Assumptions:
  # 1. The exit time of the vehicle is greater than the parking time.
  # 2. The returning time of the vehicle is greater than the exit time.
  # 3. If the difference between returning time and exit time is greater than 1 hour, the exit time will be the departure time and the vehicle will pay the fee.

  # the vehicle will come back in less than an hour
  # parking_system.departing_time = Time.now + (3_600 * 24) # 1 day after
  # parking_system.temporary_leave(small_vehicle, first_entry_point, 1, Time.now + (3_600 * 6.5), Time.now + (3_600 * 6))
  # parking_system.unpark(small_vehicle, first_entry_point, 1)

  # the vehicle will come back after more than an hour (4 hours in this case.)
  parking_system.temporary_leave(small_vehicle, first_entry_point, 1, Time.now + (3_600 * 10), Time.now + (3_600 * 6))
  # parking_system.departing_time = Time.now + (3_600 * 24)
  parking_system.unpark(small_vehicle, first_entry_point, 1)

rescue InvalidSizeError => e
  print "Invalid operation: #{e.message}"
rescue InvalidInputError => e
  print "Invalid operation: #{e.message}"
rescue DuplicationError => e
  print "Invalid operation: #{e.message}"
end
