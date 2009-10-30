# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class RegionalExclusivityExtension < Spree::Extension
  version "1.0"
  description "Restrict purchase of select products based on geographic location"
  url "http://timharvey.net/"

  # Please use regional_exclusivity/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate
    Product.class_eval do
      def regionally_protected?
        true
      end
      
      def available_to?( zipcode )
        # loop through variants
        self.variants.each do |variant| 
          # Find all the inventory units sold for the current variant
          return false unless variant.available_to?( zipcode )
        end
        true
      end
    end
      
    Variant.class_eval do
      def available_to?( zipcode )
        # Loop through each variant sold
        self.inventory_units.each do |inventory_unit| 
          if inventory_unit.state == 'sold' || inventory_unit.state == 'shipped'
            # Check the order date (to be sure it's within the protection range)
            if inventory_unit.order.within_current_season?
              # Check the distance to both the shipping and billing address?
              return false unless inventory_unit.order.within_protection_radius?( zipcode )
            end
          end
        end
        true
      end
    end
    
    Order.class_eval do
      def within_current_season?
        # If after October 10 of the current year
        if Time.now.month < 10
          # We are in Jan - Sept, so the season started the prev year
          season_start = Date.new( y=Time.now.year-1, m=10, d=1 )
        else
          # We are in Oct - Dec, so the season started the current year
          season_start = Date.new( y=Time.now.year, m=10, d=1 )
        end
        self.created_at >= season_start
      end
      
      def within_protection_radius?( zipcode )
        zip = ZipCode.find_by_zip( zipcode )
        unless zip.nil? then
          p self.bill_address.distance_to( zip ) >= 100
        else
          true
        end
      end
    end

    Address.class_eval do
      before_save   :update_geocode
      acts_as_mappable

      protected
        def update_geocode
          zip = ZipCode.find_by_zip( self.zipcode )
          self.lat = zip.latitude
          self.lng = zip.longitude
        end
    end

    Admin::BaseController.class_eval do
      before_filter :add_product_regional_ex_tab

      def add_product_regional_ex_tab
        @product_admin_tabs << {:name => t("tab_product_regional_ex"), :url => "admin_product_view_regional_ex"}
      end
    end

  end
end
