= Regional Exclusivity

This extension offers a way to give a customer "regional exclusivity" for an item for a given time and radius. In the case I created this for, a customer would have exclusive purchase protection within a 100 mile radius during a "season" that runs for 12 months of the year. The day after the season ends, the protection resets.

= Defaults

To change the radius or date range for protection, edit these values in 'regional_exclusivity_extension.rb'

    RADIUS                      = 100
    CURRENT_SEASON_START_DATE   = Date.new( y=Time.now.year, m=1, d=1 )

= Zip Data

Distance calculations rely on zip code lat/lng data and the GeoKit plugin/gem. To load GeoKit:

    script/plugin install git://github.com/andre/geokit-rails.git

The zip data is in a zips.txt. It's not the most up to date, but it's freely available and will get you close (unless you want exclusivity that's within a few miles). Put the 'regional_exclusivity/db/zips.txt' file into you Spree 'db' folder, then run:

    rake db:zip_load

If you have existing orders, after running the migrations, run this rake task to update each with the necessary lat/lng data:

    rake db:zip_info_update

= Views

This does require some customization of the views to handle the display of the regional protection lookup. I specifically blocked display of the 'add to cart' button unless the check has been passed.

The top of my product show.html.erb looks like this:

    <% if product_price(@product) %>
    <p class="prices">
      <%= t("price") %>
      <br />
      <span class="price selling"><%= product_price(@product) %></span>
    </p>
    <% end %>

    <% if @product.regionally_protected? && ( @available.nil? || !@available[:value] ) %>
      <p class="regional_exclusivity">
        <h2>Regional protection</h2>
          <%= '<h3 style="color: red;">' + @available[:message] + '</h3>' unless @available.nil? %>
          <label>Enter your zip code</label><br />
          <form action="<%= request.path %>" method="get" accept-charset="utf-8">
            <%= text_field_tag( :availableTo, '', :class => "title", :size => 6 ) %>
            &nbsp;<button type='submit' class='small'>Check Availability</button>
          </form>
      </p>
    <% else %>
      <%= '<h3 style="color: green;">' + @available[:message] + '</h3>' unless @available.nil? %>
      <% form_for :order, :url => orders_url do |f| %>
      
      ...
      
    <% end %>

