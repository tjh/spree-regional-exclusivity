class RegExBypassCode < ActiveRecord::Base
  require "digest"
  default_scope :conditions => ["expiration >= :now", { :now => Time.now }]
  named_scope :stale_codes, :conditions => ["expiration < :now", { :now => Time.now }]
  named_scope :validate, lambda { |code| { :conditions => "code = '#{code} AND expiration < #{Time.now}" } }
  before_save :verify_record
    
  def self.purge_stale_codes
    self.stale_codes.delete_all
  end
  
  def verify_record
    self.expiration = Time.now + 2.days if self.expiration.blank?
    self.code       = Digest::MD5.hexdigest( Time.now.to_s ).slice(0,5) if self.code.blank?    # Get 5 random characters
  end
  
end