class Flag < ActiveRecord::Base
  # serialize :flag, Symbol
  belongs_to :flaggable, :polymorphic => true

  # This line is dynamically generated when you call "can_flag" in your user/account model.
  # It assumes that content is owned by the same class as flaggers.
  # belongs_to :owner, :through => :flaggable, :class_name => ??

  # This is set dynamically in the plugin.
  # define "can_flag" in your user/account model.
  # belongs_to :user

  validates_presence_of :flaggable_id, :flaggable_type
  validates_presence_of :flaggable_user_id, :on => :create

  # A user can flag a specific flaggable with a specific flag once
  validates_uniqueness_of :user_id, :scope => [:flaggable_id, :flaggable_type]

  after_create :callback_flaggable
  # Pings the 'after_flagged' callback in the content model, if it exists.
  def callback_flaggable
    flaggable.callback :after_flagged
  end
  
  before_validation_on_create :set_owner_id
  #before_validation_on_create :check_reason

  def set_owner_id
    self.flaggable_user_id = flaggable.user_id
  end
  
  validates_each :reason do |record,attr,value|
    record.errors.add(attr, "don't include '#{value}' as an option") if value and !record.flaggable.reasons.include?(value.to_sym)
  end
  #def check_reason
  #  errorsraise "Reason Not Accepted" unless flaggable.class.reasons.include?(new_reason.to_sym)
  #  write_attribute :reason, new_reason
  #end

  # UNTESTED
  # # Helper class method to lookup all flags assigned
  # # to all flaggable types for a given user.
  # def self.find_flags_by_user(user)
  #   find(:all,
  #     :conditions => ["user_id = ?", user.id],
  #     :order => "created_at DESC"
  #   )
  # end
  # 
  # # Helper class method to look up all flags for 
  # # flaggable class name and flaggable id.
  # def self.find_flags_for_flaggable(flaggable_str, flaggable_id)
  #   find(:all,
  #     :conditions => ["flaggable_type = ? and flaggable_id = ?", flaggable_str, flaggable_id],
  #     :order => "created_at DESC"
  #   )
  # end
  # 
  # # Helper class method to look up a flaggable object
  # # given the flaggable class name and id 
  # def self.find_flaggable(flaggable_str, flaggable_id)
  #   flaggable_str.constantize.find(flaggable_id)
  # end
end