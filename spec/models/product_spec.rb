require File.dirname(__FILE__) + '/../spec_helper'

describe Product do

  it "should have a 'any_protection_conflicts?' method" do
    product = Product.new(:name => 'test product', :price => 9.99)
    product.any_protection_conflicts?( 46741 ).should == false
  end
  
end