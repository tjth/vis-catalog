class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :kerberos_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :token_authenticatable
  has_many :visualisations

  before_save :ensure_authentication_token
  attr_default :isAdmin, false
end
