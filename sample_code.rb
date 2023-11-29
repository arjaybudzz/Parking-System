require_relative 'models/vehicle'
require_relative 'models/parking_slot'
require_relative 'models/parking_system'
require_relative 'error/invalid_size'
require_relative 'error/invalid_input'
require 'active_support/core_ext/hash'


def parking_allocation_system
  begin
    parking_system = ParkingSystem.new
    parking_system.add_parking_slot('A', 'small')
    puts '--------------WELCOME TO OOP MALL-------------------------'
    puts '---------Please choose operations below-------------------'
    puts '1. Park a vehicle'
    puts '2. Unpark a vehicle'
    puts '3. Add parking slot'
    puts '4. Remove parking slot'
    puts '5. Add entry point'
    puts '6. Remove entry point'
    puts '7. Temporarily unpark a vehicle'

    print 'Please pick a number: '
    input = gets
    case input.chomp
    when '1'
      puts 'Please pick a vehicle size: '
      puts '1. Small'
      puts '2. Medium'
      puts '3. Large'

      print 'Please pick a number: '
      input = gets
      case input.chomp
      when '1'
        vehicle = Vehicle.new
        vehicle.size = 'Small'
        parked_vehicle = parking_system.park(vehicle)
        # puts "Vehicle of size: #{vehicle}"
        # puts "Parking lot size: #{parked_vehicle[:available][:parking_slot]}"
        # puts "Slot number: #{parked_vehicle[:slot_number]}"
        # puts "Entry point: #{parked_vehicle[:entry_point]}"
        print parked_vehicle
      when '2'
        vehicle = Vehicle.new
        vehicle.size = 'Medium'
        parked_vehicle = parking_system.park(vehicle)
        # puts "Vehicle of size: #{vehicle}"
        # puts "Parking lot size: #{parked_vehicle[:available][:parking_slot]}"
        # puts "Slot number: #{parked_vehicle[:slot_number]}"
        # puts "Entry point: #{parked_vehicle[:entry_point]}"
        print parked_vehicle
      when '3'
        vehicle = Vehicle.new
        vehicle.size = 'Large'
        parked_vehicle = parking_system.park(vehicle)
        puts "Vehicle of size: #{vehicle}"
        puts "Parking lot size: #{parked_vehicle[:available][:parking_slot]}"
        puts "Slot number: #{parked_vehicle[:slot_number]}"
        puts "Entry point: #{parked_vehicle[:entry_point]}"
      end
    when '2'
      print 'Please enter the vehicle size: '
      size = gets
      print 'Please select an entry point: '
      entry_point = gets
      print 'Please select a slot number: '
      slot_number = gets

      unparked_vehicle = parking_system.unpark(size.chomp, entry_point.chomp, slot_number.chomp.to_i)
      print unparked_vehicle
    end

    print "\n\nPress q to quit: "
    input = gets

    if input.chomp == 'q'
      parking_allocation_system
    end

  rescue InvalidSizeError => e
    print e.message
  rescue InvalidInputError => e
    print "Invalid operation: #{e.message}"
  end
end

parking_allocation_system
