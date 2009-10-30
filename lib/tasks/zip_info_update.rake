# Data from: http://www.census.gov/tiger/tms/gazetteer/zips.txt
namespace :db do
  desc "Update Address lat/lng values from Zip Codes in database." 
  task :zip_info_update => :environment do
    Address.all.each do |address|
      zip = ZipCode.find_by_zip( address.zipcode )
      unless zip.nil? then
        address.lat = zip.latitude
        address.lng = zip.longitude
        address.save!
      end
    end      
  end
end