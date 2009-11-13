# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class RegionalExclusivityExtension < Spree::Extension
  version "1.0"
  description "Restrict purchase of select products based on geographic location"
  url "http://timharvey.net/"
  
  RADIUS                      = 100
  CURRENT_SEASON_START_DATE   = Time.now.month < 10 ? Date.new( y=Time.now.year-1, m=10, d=1 ) : Date.new( y=Time.now.year, m=10, d=1 )
  
  def any_protection_conflicts?( orders, product, zipcode )
    # Loop through all orders
    orders.each do |order|
      if order.within_protection_radius?( zipcode )
        # check every line item
        order.line_items.each do |line_item|
          # If a line item matches the product under consideration, there is a conflict
          return true if !line_item.variant.nil? && line_item.variant.product == product
        end
      end
    end
    false
  end
  
  def activate
    ProductsController.class_eval do
      before_filter :setAvailabilityMessage, :only => :show
      
      def setAvailabilityMessage
        return if params[:availableTo].nil?

        zip_input = params[:availableTo]
        @available = { :value => FALSE, :message => ''}
        
        # See if what the user provided is a valid (not expired) bypass code
        if RegExBypassCode.validate params[:availableTo]
          @available[:message]  = t("protection_bypassed")
          @available[:value]    = true
        else
          # Now see if their zip works
          unless zip_input.to_i && zip_input.to_i.to_s.length == 5
            @available[:message]  = t("invalid_zip_code")
          else
            if RegionalExclusivityExtension::any_protection_conflicts?( Order.current_season_orders, @product, params[:availableTo])
              @available[:message]  = t("protected_in_given_region") + params[:availableTo] + '.'
            else
              @available[:message]  = t("availabile_in_given_region") + params[:availableTo] + '.'
              @available[:value]    = true
            end
          end
        end
        @available
      end
    end
    
    Product.class_eval do
      def regionally_protected?
        true
      end
      
      def any_protection_conflicts?( zipcode )
        RegionalExclusivityExtension::any_protection_conflicts?( Order.current_season_orders, self, zipcode )
      end      
    end
    
    Order.class_eval do
      named_scope :current_season_orders, :conditions => [ "created_at >= ?", RegionalExclusivityExtension::CURRENT_SEASON_START_DATE ]

      def within_current_season?
        self.created_at >= RegionalExclusivityExtension::CURRENT_SEASON_START_DATE
      end
      
      def within_protection_radius?( zipcode )
        return false if self.bill_address.nil?
        zip = ZipCode.find_by_zip( zipcode )
        zip.nil? || self.bill_address.distance_to( zip ) <= RegionalExclusivityExtension::RADIUS
      end
      
    end

    Address.class_eval do
      before_save   :update_geocode
      acts_as_mappable

      protected
        def update_geocode
          zip = ZipCode.find_by_zip( self.zipcode )
          unless zip.nil?
            self.lat = zip.latitude
            self.lng = zip.longitude
          end
        end
    end

    Admin::ConfigurationsController.class_eval do
      before_filter :add_reg_ex_bypass_codes_link, :only => :index

      def add_reg_ex_bypass_codes_link
        @extension_links << {:link => admin_reg_ex_bypass_codes_path, :link_text => t('tab_reg_ex_bypass_codes'), :description => t('tab_reg_ex_bypass_codes_desc')}
      end
    end

  end
end
