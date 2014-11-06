class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :kerberos_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable
  has_many :visualisations
end
