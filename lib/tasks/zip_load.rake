# Code per: http://ianconnor.blogspot.com/2007/03/importing-zip-codes.html
# Data from: http://www.census.gov/tiger/tms/gazetteer/zips.txt
namespace :db do
  desc "Load Zip Codes into database from db directory." 
  task :zip_load => :environment do
    require 'csv'
    ZipCode.delete_all
    CSV.open("#{RAILS_ROOT}/db/zips.txt", "r") do |row|
      zip = ZipCode.new
      zip.zip = row[1]
      zip.state = row[2]
      zip.town = row[3]
      zip.longitude = row[4]
      zip.latitude = row[5]
      zip.save!
    end
  end
end