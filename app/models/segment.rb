require 'earth'
require 'earth/locality/zip_code'

class Segment
  include Carbon

  emit_as :shipment do
    provide :weight
    provide :package_count
    provide :carrier, :key => :name
    provide :origin, :as => :origin_zip_code
    provide :final_destination, :as => :destination_zip_code
    provide :mode_name, :as => :mode
    provide :segment_count
  end

  attr_accessor :origin, :depart, :destination, :arrive,
    :weight, :package_count, :mode

  def initialize(options = {})
    options.each do |name, value|
      self.send "#{name}=", value
    end
  end

  def carrier
    'FedEx'
  end

  def segment_count
    1
  end

  def origin_zip_code
    @origin_zip_code ||= ZipCode.find_by_name(origin)
  end

  def final_destination
    destination || origin
  end

  def destination_zip_code
    @destination_zip_code ||= ZipCode.find_by_name(destination)
  end

  def length
    if origin_zip_code and destination_zip_code
      origin_zip_code.distance_to destination_zip_code
    else
      0
    end
  end

  def departure
    Time.parse(depart.to_s)
  end
  
  def arrival
    arrive ? Time.parse(arrive.to_s) : nil
  end
  
  def duration # in seconds
    if arrival and departure
      arrival - departure
    else
      0
    end
  end
  
  def duration_in_minutes
    duration / 60
  end
  
  def duration_in_hours
    duration_in_minutes / 60
  end
  
  def speed
    if duration_in_hours > 0
      length / duration_in_hours
    else
      0
    end
  end
  
  def mode
    speed < 80 ? :ground : :air
  end

  def mode_name
    mode.to_s.humanize
  end

  def mode_with_indefinite_article
    case mode
    when :courier, :ground
      'a ground'
    when :air
      'an air'
    end
  end
  
  def origin_city
    origin_zip_code.try(:description)
  end
  
  def destination_city
    destination_zip_code.try(:description)
  end

  def in_town?
    origin_city == destination_city || destination.nil?
  end
  
  def range
    if in_town?
      "Within #{origin_city}"
    else
      "#{origin_city}&ndash;#{destination_city}"
    end
  end

  def footprint
    emission_estimate.number
  end

  def methodology
    emission_estimate.methodology
  end
end
