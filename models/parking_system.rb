require 'active_support/core_ext/hash'

class ParkingSystem
  MIN_ENTRY_POINTS = 3
  EMPTY = 'none'.freeze
  RATES = { FLAT_RATE: 40, SMALL_RATE: 20, MEDIUM_RATE: 60, LARGE_RATE: 100, DAILY_RATE: 5_000 }.freeze
  TIME_CONSTANTS = { HOURS_PER_DAY: 24, SECONDS_PER_HOUR: 3_600, MINIMUM_HOURS: 3 }.freeze

  attr_reader :parking_slots, :parking_time, :departing_time

  def initialize
    @parking_slots = defaults[:initial_entry_points]
    @parking_time = defaults[:initial_time]
    @departing_time = defaults[:initial_time]
  end

  def departing_time=(value)
    raise InvalidInputError, "#{value} is not a valid time format" unless value.instance_of?(Time)
    raise InvalidInputError, "#{value} must be greater than the parking time." if value < parking_time

    @departing_time = value
  end

  def add_entry_point(entry_point)
    unless entry_point.instance_of?(String) || entry_point.instance_of?(Integer)
      raise InvalidInputError, "Expected type String or Integer but received type #{entry_point.class}"
    end

    raise DuplicationError, 'Entry point already exists.' if already_exist?(entry_point)

    parking_slots[entry_point] = []
    puts "Entry point #{entry_point} has been added."
  end

  def remove_entry_point(entry_point)
    raise InvalidInputError, 'Minimum number of entry points reached.' if minimum_threshold_reached?

    unless already_exist?(entry_point)
      raise InvalidInputError, "You did not create entry point #{entry_point}. Removal is invalid."
    end

    unless entirely_available?(entry_point)
      raise InvalidInputError, "Entry point #{entry_point} is still occupied. Removal is invalid."
    end

    parking_slots.delete(entry_point)
    puts "Entry point #{entry_point} has been removed."
  end

  def add_parking_slot(entry_point, parking_slot_size)
    raise InvalidInputError, "Entry point #{entry_point} does not exist." unless already_exist?(entry_point)

    parking_slots[entry_point].push(additional_parking_slot(parking_slot_size))
    puts "Parking Slot of size #{parking_slot_size} has been added to entry point #{entry_point}."
  end

  # You cannot remove a parking slot at the middle
  def remove_parking_slot(entry_point)
    raise InvalidInputError, "Entry point #{entry_point} does not exist." unless already_exist?(entry_point)

    unless parking_slots[entry_point].last[:occupying_vehicle_size] == EMPTY
      raise InvalidInputError, 'The last parking slot is still occupied.'
    end

    parking_slots[entry_point].pop
    parking_slots[entry_point]
    print "The last parking slot at entry point #{entry_point} has been removed."
  end

  def park(vehicle)
    vehicle_info = add_vehicle(vehicle)

    if vehicle_info.nil?
      raise InvalidInputError, "There are no more available parking slot for vehicle of size #{vehicle}."
    end

    puts "Vehicle size: #{vehicle}"
    puts "Parking slot size: #{vehicle_info[:available][:parking_slot]}"
    puts "Slot number: #{vehicle_info[:slot_number]}"
  end

  def unpark(vehicle, entry_point, slot_number)
    selected_slot = remove_vehicle(vehicle, entry_point, slot_number)
    fee = format('%.2f', calculate_fee(selected_slot[:parking_slot]))
    print "Please pay an amount of P#{fee}\n"
  end

  # It is assumed here that the exit time is 1 hour after the initial parking time.
  def temporary_leave(vehicle, entry_point, slot_number, returning_time, exit_time = defaults[:initial_time] + TIME_CONSTANTS[:SECONDS_PER_HOUR])
    raise InvalidInputError, 'Returning time must be greater than exit time' if returning_time < exit_time

    difference = (returning_time - exit_time) / TIME_CONSTANTS[:SECONDS_PER_HOUR]

    if difference > 1
      @departing_time = exit_time
      unpark(vehicle, entry_point, slot_number)
      @parking_time = returning_time
      park(vehicle)
    end

    return
  end

  def view_map
    parking_slots.each_pair do |entry_point, parking_slot|
      puts "-----------AT ENTRY POINT #{entry_point.capitalize}---------------"
      parking_slot.each_with_index do |parking_slot_info, index|
        puts "Parking slot size: #{parking_slot_info[:parking_slot]}"
        puts "Occupying vehicle size: #{parking_slot_info[:occupying_vehicle_size]}"
        puts "Slot number: #{parking_slot_number(index)}"
      end
    end
  end

  private

  def defaults
    { initial_entry_points: { A: [], B: [], C: [] }.with_indifferent_access, initial_time: Time.now }
  end

  def already_exist?(entry_point)
    return parking_slots.key?(entry_point)
  end

  def curr_num_entry_points
    return parking_slots.size
  end

  def vehicle_fit?(vehicle, parking_slot)
    return vehicle <= parking_slot
  end

  def minimum_threshold_reached?
    return curr_num_entry_points <= MIN_ENTRY_POINTS
  end

  def parking_slot_number(index)
    return index + 1
  end

  def generate_parking_slot(size)
    parking_slot = ParkingSlot.new
    parking_slot.size = size
    return parking_slot
  end

  def additional_parking_slot(size)
    { occupying_vehicle_size: EMPTY, parking_slot: generate_parking_slot(size) }
  end

  # Checks the entire parking slot to see if there is a vehicle occupying
  def entirely_available?(entry_point)
    parking_slots[entry_point].each do |parking_slot|
      return false unless parking_slot[:parking_slot].vacant?
    end

    return true
  end

  # Checks a parking slot to see if it's empty and it is compatible with the vehicle
  def available?(vehicle, parking_slot)
    return true if parking_slot.vacant? && vehicle_fit?(vehicle, parking_slot)

    return false
  end

  # returns a vacant parking slot for the vehicle
  def check_vacancy(entry_point, vehicle)
    available_slot = {}

    parking_slots[entry_point].each_with_index do |parking_slot, index|
      if available?(vehicle, parking_slot[:parking_slot])
        available_slot[:available] = parking_slot
        available_slot[:slot_number] = parking_slot_number(index)
        available_slot[:entry_point] = entry_point
        break
      end
    end

    return available_slot
  end

  def find(vehicle, entry_point, slot_number)
    parking_slots[entry_point].each_with_index do |parking_slot, index|
      if parking_slot[:occupying_vehicle_size] == vehicle.to_s && parking_slot_number(index) == slot_number
        return parking_slot
      end
    end

    return nil
  end

  def add_vehicle(vehicle)
    unless vehicle.instance_of?(Vehicle)
      raise InvalidInputError, "Expected argument of type Vehicle but receives argument of type #{vehicle.class}"
    end

    available_slot = {}

    parking_slots.each_key do |entry_point|
      available_slot = check_vacancy(entry_point, vehicle)
      break unless available_slot.empty?
    end

    unless available_slot.empty?
      available_slot[:available][:occupying_vehicle_size] = vehicle.to_s
      available_slot[:available][:parking_slot].occupy
      return available_slot
    end

    return nil
  end

  def remove_vehicle(vehicle, entry_point, slot_number)
    vehicle_info = find(vehicle, entry_point, slot_number)

    if vehicle_info.nil?
      raise InvalidInputError, "Entry point #{entry_point}, Slot number #{slot_number} is not occupying any vehicle"
    end

    vehicle_info[:occupying_vehicle_size] = EMPTY
    vehicle_info[:parking_slot].vacate
    return vehicle_info
  end

  def consumed
    difference = format('%.2f', ((departing_time - parking_time) / TIME_CONSTANTS[:SECONDS_PER_HOUR]))
    return difference.to_f.ceil # to round up
  end

  def daily_pay
    return RATES[:DAILY_RATE] * (consumed / TIME_CONSTANTS[:HOURS_PER_DAY]).to_i
  end

  def excess(hour_time)
    return hour_time % TIME_CONSTANTS[:HOURS_PER_DAY]
  end

  def hourly_pay(parking_slot, time_spent)
    return RATES[:FLAT_RATE] if time_spent <= TIME_CONSTANTS[:MINIMUM_HOURS]

    case parking_slot.to_s
    when 'Small'
      RATES[:SMALL_RATE] * (time_spent - TIME_CONSTANTS[:MINIMUM_HOURS]) + RATES[:FLAT_RATE]
    when 'Medium'
      RATES[:MEDIUM_RATE] * (time_spent - TIME_CONSTANTS[:MINIMUM_HOURS]) + RATES[:FLAT_RATE]
    when 'Large'
      RATES[:LARGE_RATE] * (time_spent - TIME_CONSTANTS[:MINIMUM_HOURS]) + RATES[:FLAT_RATE]
    end
  end

  def calculate_fee(parking_slot)
    if excess(consumed).zero?
      return daily_pay
    elsif consumed > TIME_CONSTANTS[:HOURS_PER_DAY] && excess(consumed).positive?
      return daily_pay + hourly_pay(parking_slot, excess(consumed))
    else
      return hourly_pay(parking_slot, consumed)
    end
  end
end
