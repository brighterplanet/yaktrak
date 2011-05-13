class Tracking < ActiveRecord::Base
  class Failure < StandardError; end
  class International < StandardError; end
  class NoSegmentInformation < StandardError; end

  set_primary_key :package_identifier
  attr_accessible :package_identifier
  
  def request_data
    { 'wsdl:WebAuthenticationDetail' => {
        'wsdl:UserCredential' => {
          'wsdl:Key' => FEDEX[:key],
          'wsdl:Password' => FEDEX[:password],
          :order! => ['wsdl:Key', 'wsdl:Password']
        }
      },
      'wsdl:ClientDetail' => {
        'wsdl:AccountNumber' => FEDEX[:account],
        'wsdl:MeterNumber' => FEDEX[:meter]
      },
      'wsdl:Version' => {
        'wsdl:ServiceId' => 'trck',
        'wsdl:Major' => '4',
        'wsdl:Intermediate' => '1',
        'wsdl:Minor' => '0'
      },
      'wsdl:PackageIdentifier' => {
        'wsdl:Value' => package_identifier.to_s,
        'wsdl:Type' => 'TRACKING_NUMBER_OR_DOORTAG',
        :order! => ['wsdl:Value', 'wsdl:Type']
      },
      'wsdl:IncludeDetailedScans' => 'true',
      :order! => [ 'wsdl:WebAuthenticationDetail', 'wsdl:ClientDetail', 'wsdl:Version', 'wsdl:PackageIdentifier', 'wsdl:IncludeDetailedScans']
    }
  end

  def international?(response)
    return true if response[:track_reply][:track_details] && response[:track_reply][:track_details][:service_info] =~ /International/i
    return response[:track_reply][:track_details][:events].any? { |e| e[:address][:country_code] != 'US' }
  end

  def tracking_response
    return @tracking_response unless @tracking_response.nil? 
    response = $soap_client.request :track do
      soap.input = 'wsdl:TrackRequest'
      soap.body = request_data
    end.to_hash
    if response[:track_reply][:highest_severity] == 'ERROR'
      raise Failure, "Failed to find tracking information for #{package_identifier}" 
    elsif international?(response)
      raise International
    end
    @tracking_response = response
  end
  
  def tracking_details
    tracking_response[:track_reply][:track_details]
  end

  def weight
    if tracking_details[:package_weight]
      tracking_details[:package_weight][:value]
    end
  end

  def package_count
    if tracking_details[:package_count] && tracking_details[:package_count].to_i > 0
      tracking_details[:package_count]
    else
      1
    end
  end
  
  def events
    if tracking_details[:events].respond_to?(:keys)
      raise NoSegmentInformation
    else
      events = tracking_details[:events]
    end
    events.map do |event|
      Event.new event[:address][:postal_code], event[:timestamp], event[:event_type] 
    end.reverse
  end
  
  def segments
    @segments ||= events.select(&:zipcode).inject([]) do |memo, event|
      if memo.empty?
        memo << Segment.new(:origin => event.zipcode, :depart => event.timestamp,
                            :weight => weight, :package_count => package_count)
      elsif memo.last.origin == event.zipcode and not memo.last.destination
        memo.last.depart = event.timestamp
      elsif memo.last.destination and memo.last.destination == event.zipcode
        memo << Segment.new(:origin => event.zipcode, :depart => event.timestamp,
                            :weight => weight, :package_count => package_count)
      elsif memo.last.destination
        memo << Segment.new(:origin => memo.last.destination, :depart => memo.last.arrival,
                            :destination => event.zipcode, :arrive => event.timestamp,
                            :weight => weight, :package_count => package_count)
      else
        memo.last.destination = event.zipcode
        memo.last.arrive = event.timestamp
      end

      if memo.last.depart.nil?
        previous = memo[memo.length - 2]
        memo.last.depart = previous.arrive || previous.depart
      end

      memo
    end
  end
  
  def delivered?
    events.find { |e| e.delivery? }.present?
  end
  
  def status
    delivered? ? :delivered : :en_route
  end

  def footprint
    @footprint ||= segments.empty? ? 0 : segments.sum(&:footprint).round
  end
end
