class Guidance < ActiveRecord::Base

  #String :value
  #String :user

  has_many :wickets

  validates :value, :user, :presence => { :message => "is required!" }

  validates :value,
    :length => { :minimum => 1, :maximum => 20 },
    :uniqueness => { :message => "already exists!" },
    :unless => lambda{ self.value.blank? }

end
