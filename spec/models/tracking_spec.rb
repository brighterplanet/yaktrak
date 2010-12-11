require 'spec_helper'

describe Tracking do
  let(:bad_response) do
    s = {
      :track_reply => {
        :highest_severity => 'ERROR',
        :notifications => {
          :severity => 'ERROR',
          :source => 'trck',
          :code => '9040',
          :message => 'No information for the following shipments has been received by our system yet.  Please try again or contact Customer Service at 1.800.Go.FedEx(R) 800.463.3339.',
          :localized_message => 'No information for the following shipments has been received by our system yet.  Please try again or contact Customer Service at 1.800.Go.FedEx(R) 800.463.3339.'
        }
      }
    }
  end
  let(:good_response) do
    s = {
      :track_reply => {
        :highest_severity => 'SUCCESS',
        :notifications => {
          :severity => 'SUCCESS',
          :source => 'trck',
          :code => '0',
          :message => 'Request was successfully processed.',
          :localized_message => 'Request was successfully processed.'
        },
        :track_details => {
          :TrackingNumber => '382544330058603',
          :TrackingNumberUniqueIdentifier => '12010~382544330058603',
          :StatusCode => 'DL',
          :StatusDescription => 'Delivered',
          :CarrierCode => 'FDXG',
          :ServiceInfo => 'FedEx Ground-U.S.',
          :ServiceType => 'FEDEX_GROUND',
          :package_weight => {
            :units => 'LB',
            :value => '19.0'
          },
          :packaging => 'Package',
          :packageSequenceNumber => '1',
          :package_count => '1',
          :origin_location_address => {
            :City => 'TOPEKA',
            :StateOrProvinceCode => 'KS',
            :country_code => 'US',
            :residential => 'false'
          },
          :Shiptimestamp => '2010-05-10T00:00:00',
          :Destinationaddress => {
            :City => 'Windsor',
            :StateOrProvinceCode => 'CO',
            :country_code => 'US',
            :residential => 'false'
          },
          :ActualDeliverytimestamp => '2010-05-12T08:59:14-06:00',
          :ActualDeliveryaddress => {
            :City => 'Fort Collins',
            :StateOrProvinceCode => 'CO',
            :country_code => 'US',
            :residential => 'false'
          },
          :DeliverySignatureName => 'AHANSEN',
          :SignatureProofOfDeliveryAvailable => 'true',
          :ProofOfDeliveryNotificationsAvailable => 'false',
          :ExceptionNotificationsAvailable => 'false',
          :RedirectToHoldEligibility => 'INELIGIBLE',
          :events => [
            {
              :timestamp => '2010-05-12T08:59:14-06:00',
              :event_type => 'DL',
              :event_description => 'Delivered',
              :address => {
                :City => 'Fort Collins',
                :StateOrProvinceCode => 'CO',
                :postal_code => '80528',
                :country_code => 'US',
                :residential => 'false',
              },
              :ArrivalLocation => 'DELIVERY_LOCATION',
            },
            {
              :timestamp => '2010-05-12T05:46:00-06:00',
              :event_type => 'OD',
              :event_description => 'On FedEx vehicle for delivery',
              :address => {
                :City => 'JOHNSTOWN',
                :StateOrProvinceCode => 'CO',
                :postal_code => '80534',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'VEHICLE',
            },
            {
              :timestamp => '2010-05-12T03:20:10-06:00',
              :event_type => 'AR',
              :event_description => 'At local FedEx facility',
              :address => {
                :City => 'JOHNSTOWN',
                :StateOrProvinceCode => 'CO',
                :postal_code => '80534',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'DESTINATION_FEDEX_FACILITY'
            },
            {
              :timestamp => '2010-05-12T02:30:24-06:00',
              :event_type => 'DP',
              :event_description => 'Departed FedEx location',
              :address => {
                :City => 'HENDERSON',
                :StateOrProvinceCode => 'CO',
                :postal_code => '80640',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'FEDEX_FACILITY',
            },
            {
              :timestamp => '2010-05-11T20:04:00-06:00',
              :event_type => 'AR',
              :event_description => 'Arrived at FedEx location',
              :address => {
                :City => 'HENDERSON',
                :StateOrProvinceCode => 'CO',
                :postal_code => '80640',
                :country_code => 'US',
                :residential => 'false',
              },
              :ArrivalLocation => 'FEDEX_FACILITY'
            },
            {
              :timestamp => '2010-05-11T07:29:20-05:00',
              :event_type => 'DP',
              :event_description => 'Departed FedEx location',
              :address => {
                :City => 'LENEXA',
                :StateOrProvinceCode => 'KS',
                :postal_code => '66227',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'FEDEX_FACILITY'
            },
            {
              :timestamp => '2010-05-11T01:43:00-05:00',
              :event_type => 'AR',
              :event_description => 'Arrived at FedEx location',
              :address => {
                :City => 'LENEXA',
                :StateOrProvinceCode => 'KS',
                :postal_code => '66227',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'FEDEX_FACILITY'
            },
            {
              :timestamp => '2010-05-10T21:41:17-05:00',
              :event_type => 'DP',
              :event_description => 'Left FedEx origin facility',
              :address => {
                :City => 'TOPEKA',
                :StateOrProvinceCode => 'KS',
                :postal_code => '66619',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'ORIGIN_FEDEX_FACILITY'
            },
            {
              :timestamp => '2010-05-10T18:55:00-05:00',
              :event_type => 'AR',
              :event_description => 'Arrived at FedEx location',
              :address => {
                :City => 'TOPEKA',
                :StateOrProvinceCode => 'KS',
                :postal_code => '66619',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'FEDEX_FACILITY'
            },
            {
              :timestamp => '2010-05-10T16:52:00-05:00',
              :event_type => 'PU',
              :event_description => 'Picked up',
              :address => {
                :City => 'TOPEKA',
                :StateOrProvinceCode => 'KS',
                :postal_code => '66619',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'PICKUP_LOCATION'
            },
            {
              :timestamp => '2010-05-08T08:32:00-05:00',
              :event_type => 'OC',
              :event_description => 'Shipment information sent to FedEx',
              :address => {
                :postal_code => '66619',
                :country_code => 'US',
                :residential => 'false'
              },
              :ArrivalLocation => 'CUSTOMER'
            }
          ]
        }
      }
    }
  end
  let(:tracking) { Tracking.new :package_identifier => '56901001514000381668' }

  it 'should calculate emissions based on a tracking number'
  it 'should retrieve events for a valid delivery'

  describe '#tracking_response' do
    it 'should return the hash of tracking details' do
      $soap_client.stub!(:track).and_return good_response
      tracking.tracking_response.should be_a_kind_of(Hash)
    end
    it 'should raise an error if an invalid number is entered' do
      $soap_client.stub!(:track).and_return bad_response
      expect do
        tracking.tracking_response
      end.should raise_error(Tracking::Failure)
    end
  end

  describe '#weight' do
    it 'should return the package weight in lbs' do
      $soap_client.stub!(:track).and_return good_response
      tracking.weight.should == '19.0'
    end
    it 'should return nil if no weight is given' do
      no_weight_response = good_response
      no_weight_response[:track_reply][:track_details].delete :package_weight
      $soap_client.stub!(:track).and_return no_weight_response
      tracking.weight.should be_nil
    end
  end

  describe '#package_count' do
    it 'should return the package package count' do
      $soap_client.stub!(:track).and_return good_response
      tracking.package_count.should == '1'
    end
    it 'should return nil if no package count is given' do
      no_package_count_response = good_response
      no_package_count_response[:track_reply][:track_details].delete :package_count
      $soap_client.stub!(:track).and_return no_package_count_response
      tracking.package_count.should be_nil
    end
  end

  describe '#delivered?' do
    it 'should return true if there is a delivery event' do
      delivery_event = mock Event, :delivery? => true
      tracking.stub!(:events).and_return [delivery_event]
      tracking.should be_delivered
    end
    it 'should return false if there is no delivery event' do
      event = mock Event, :delivery? => false
      tracking.stub!(:events).and_return [event]
      tracking.should_not be_delivered
    end
  end

  describe '#status' do
    it 'should return :delivered if package is delivered' do
      tracking.stub!(:delivered?).and_return true
      tracking.status.should == :delivered
    end
    it 'should return :en_route if package is not delivered' do
      tracking.stub!(:delivered?).and_return false
      tracking.status.should == :en_route
    end
  end

  describe '#footprint' do
    it 'should return the sum of footprints for each segment' do
      seg1 = mock Segment, :footprint => 34
      seg2 = mock Segment, :footprint => 44
      seg3 = mock Segment, :footprint => 54
      tracking.stub!(:segments).and_return [seg1, seg2, seg3]
      tracking.footprint.should == 132
    end
    it 'should return 0 if there are no segments' do
      tracking.stub!(:segments).and_return []
      tracking.footprint.should == 0
    end
  end

  describe '#segments' do
    it 'should return an empty array if there are no events' do

    end
  end
end

