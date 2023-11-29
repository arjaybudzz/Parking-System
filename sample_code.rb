# frozen_string_literal = true

require_relative 'models/vehicle'
require_relative 'models/parking_slot'
require_relative 'models/parking_system'
require_relative 'error/invalid_size'
require_relative 'error/invalid_input'
require 'active_support/core_ext/hash'

begin
  parking_system = ParkingSystem.new
  parking_slot_size = 'small'
  parking_system.add_parking_slot('A', parking_slot_size)
  parking_system.departing_time = Time.now + 23_040
  parking_slot = parking_system.parking_slots['A'].first[:parking_slot]
  difference = format('%.2f', ((parking_system.departing_time - parking_system.parking_time) / 3_600))
  formatted_difference = format('%.2f', difference.to_f.ceil)
  vehicle = Vehicle.new
  vehicle.size = 'small'

  print parking_system.calculate_fee(parking_slot)
  # print formatted_difference
  # print parking_system.additional_pay(parking_slot)
  # print parking_system.additional_pay(parking_slot, parking_system.consumed(parking_system.departing_time))
  # print parking_system.consumed
  # print parking_system.hourly_pay(parking_slot, 24)
  # print parking_system.daily_pay
  # excess = (25 / 24.to_f) - (25 / 24)
  # print parking_system.excess(25)

  # hash_table = { Small: -1, Medium: 0, Large: 1 }
  # print hash_table.key(-1)

  # parking_system.park(vehicle)
  # print parking_system.unpark(vehicle, 'A', 1)
  # def some_func(arr)
  #   arr.pop
  #   arr
  # end

  # array = [1, 2, 3, 4, 5, 6]

  # print some_func(array)
rescue InvalidSizeError => e
  print e.message
rescue InvalidInputError => e
  print e.message
end
