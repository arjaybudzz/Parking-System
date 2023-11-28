require 'active_support/core_ext/hash'

class ParkingSystem
  MIN_ENTRY_POINTS = 3
  EMPTY = 'none'.freeze
  RATES = { FLAT_RATE: 40, SMALL_RATE: 20, MEDIUM_RATE: 60, LARGE_RATE: 100, DAILY_RATE: 5_000 }.freeze

  attr_reader :parking_slots

  def initialize(parking_slots: { A: [], B: [], C: [] })
    @parking_slots = parking_slots.with_indifferent_access
    @parking_time = Time.new
    @departing_time = Time.new
  end

  def add_entry_point(entry_point)
    unless entry_point.instance_of?(String) || entry_point.instance_of?(Integer)
      raise InvalidInputError, 'Please enter a valid input'
    end

    raise DuplicationError, 'Entry point already exists.' if already_exist?(entry_point)

    parking_slots[entry_point] = []
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
  end

  def add_parking_slot(entry_point, parking_slot_size)
    raise InvalidInputError, 'Please enter a valid input' unless entry_point.instance_of?(String)

    parking_slots[entry_point] << additional_parking_slot(parking_slot_size)
  end

  def park(vehicle)
    add_vehicle(vehicle)
  end

  def unpark(vehicle, entry_point, slot_number)
    remove_vehicle(vehicle, entry_point, slot_number)
  end

  private

  def parking_time
    @parking_time
  end

  def departing_time
    @departing_time
  end

  def entirely_available?(entry_point)
    parking_slots[entry_point].each do |parking_slot|
      return false unless parking_slot[:parking_slot].vacant?
    end

    return true
  end

  def available?(vehicle, parking_slot)
    return true if parking_slot.vacant? && vehicle_fit?(vehicle, parking_slot)

    return false
  end

  def already_exist?(entry_point)
    return parking_slots.key?(entry_point)
  end

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

  def curr_num_entry_points
    parking_slots.size
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
    ParkingSlot.new(size: size)
  end

  def additional_parking_slot(size)
    { occupying_vehicle_size: EMPTY, parking_slot: generate_parking_slot(size) }
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
    raise InvalidInputError, 'Invalid vehicle type input' unless vehicle.instance_of?(Vehicle)

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

  def calculate_fee(parking_slot)
    daily_pay(consumed) + additional_pay(parking_slot, consumed) + RATES[:FLAT_RATE]
  end

  def additional_pay(parking_slot, time_spent)
    case parking_slot.to_s
    when parking_slot.to_s == ParkingSlot::SIZES[:Small]
      RATES[:SMALL_RATE] * time_spent
    when parking_slot.to_s == ParkingSlot::SIZES[:Medium]
      RATES[:MEDIUM_RATE] * time_spent
    when parking_slot.to_s == ParkingSlot::SIZES[:Large]
      RATES[:LARGE_RATE] * time_spent
    end
  end

  def daily_pay(time_spent)
    RATES[:DAILY_RATE] * time_spent % 24
  end

  def consumed
    hourly_time = (departing_time - parking_time) / 3_600

    return 0 if hourly_time < 3

    return hourly_time % 24 if hourly_time >= 24

    return hourly_time
  end
end
