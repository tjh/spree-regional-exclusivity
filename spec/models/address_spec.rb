require File.dirname(__FILE__) + '/../spec_helper'

describe Address do
  include AddressSpecHelper

  # Build up a set of products and orders to test availability against
  before(:each) do
    @address = Address.new
    @address.attributes = valid_address_attributes
  end
    
  it "should update the address lat/lng values 'before_save'" do
    lng = 84.940593
    lat = 41.210753
    zip46741 = ZipCode.create!(
      :zip => 46741,
      :longitude  => lng,
      :latitude   => lat
    )
    @address.zipcode = 46741
    @address.save!
    @address.lng.should == lng
    @address.lat.should == lat
  end  
end