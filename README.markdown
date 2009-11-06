= Regional Exclusivity

This extension offers a way to give a customer "regional exclusivity" for an item for a given time and radius. In the case I created this for, a customer would have exclusive purchase protection within a 100 mile radius during a "season" that runs for 12 months of the year. The day after the season ends, the protection resets.

= Defaults

To change the radius or date range for protection, edit these values in 'regional_exclusivity_extension.rb'

    RADIUS                      = 100
    CURRENT_SEASON_START_DATE   = Date.new( y=Time.now.year, m=1, d=1 )

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

