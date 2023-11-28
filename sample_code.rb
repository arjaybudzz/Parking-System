# frozen_string_literal = true

require_relative 'models/vehicle'
require_relative 'models/parking_slot'
require_relative 'models/parking_system'
require_relative 'error/invalid_size'
require_relative 'error/invalid_input'
require 'active_support/core_ext/hash'

begin
  parking_system = ParkingSystem.new
  print parking_system.parking_time
rescue InvalidSizeError => e
  print e.message
rescue InvalidInputError => e
  print e.message
end
