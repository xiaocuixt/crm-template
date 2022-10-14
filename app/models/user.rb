class User < ApplicationRecord
  attr_accessor :account

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_roles
  has_many :roles, through: :user_roles

  class << self
    def backend_search(opts)
      return all if opts[:keyword].blank?
      where("mobile like :key OR email like :key", key: "%#{opts[:keyword]}%")
    end
  end
end
