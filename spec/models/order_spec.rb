require File.dirname(__FILE__) + '/../spec_helper'

describe Order do
  include AddressSpecHelper

  # Build up a set of products and orders to test availability against
  before(:each) do
    @product = Product.create(:name => 'Test product', :price => 1999)
    @order   = Order.new
    @orders  = []
  end
  
  it "should be within the current season if created today" do
    @order.created_at = Time.now
    @order.within_current_season?
  end
  
  it "should not be within the current season if created a year ago" do
    @order.created_at = Time.now - 1.year
    @order.within_current_season?.should == false
  end
  
  it "should not be within the current season if created a year ago" do
    @order.created_at = Time.now - 1.year
    @order.within_current_season?.should == false
  end
  
  it "should indicate that 46805 is within the protection radius for 46741" do
    zip46741 = ZipCode.create!(
      :zip => 46741,
      :longitude  => 84.940593,
      :latitude   => 41.210753
    )
    zip46805 = ZipCode.create!(
      :zip => 46805,
      :longitude  => 85.118865,
      :latitude   => 41.097663
    )
    bill_address = double('bill_address')
    bill_address.stub(:distance_to).and_return( 20 )
    @order.bill_address = bill_address
    @order.within_protection_radius?( 46805 ).should == true
  end
  
  it "should indicate that 90210 is not within the protection radius for 46741" do
    zip46741 = ZipCode.create!(
      :zip => 46741,
      :longitude  => 84.940593,
      :latitude   => 41.210753
    )
    zip46805 = ZipCode.create!(
      :zip => 90210,
      :longitude  => 118.406477,
      :latitude   => 34.090107
    )
    bill_address = double('bill_address')
    bill_address.stub(:distance_to).and_return( 2000 )
    @order.bill_address = bill_address
    @order.within_protection_radius?( 90210 ).should == false
  end
  
  it "should not find regional protection conflicts when there are no orders" do
    RegionalExclusivityExtension::any_protection_conflicts?( @orders, @product, 46741 ).should_not == true
  end
  
  it "should not find protection conflicts when there are no line items" do
    @orders << @order
    RegionalExclusivityExtension::any_protection_conflicts?( @orders, @product, 46741 ).should_not == true    
  end
  
  it "should find protection conflicts when an order has the product as a matching line item" do
    ZipCode.create!( :zip => 46741 )
    bill_address = double('bill_address')
    bill_address.stub(:distance_to).and_return( 0 )
    @order.bill_address = bill_address
    @order.add_variant(@product.master)
    @orders << @order
    RegionalExclusivityExtension::any_protection_conflicts?( @orders, @product, 46741 ).should == true  
  end

  it "should find protection conflicts when checking a bogus zip code" do
    ZipCode.create!( :zip => 46741 )
    bill_address = double('bill_address')
    bill_address.stub(:distance_to).and_return( 0 )
    @order.bill_address = bill_address
    @order.add_variant(@product.master)
    @orders << @order
    RegionalExclusivityExtension::any_protection_conflicts?( @orders, @product, 00000 ).should == true  
  end

  
end