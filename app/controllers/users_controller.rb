class UsersController < ApplicationController
  before_filter :authenticate_user!

  def make_admin
    if current_user.isAdmin
      u = User.find(params[:userid])
      if u.present?
        u.isAdmin = true
        u.save!
      end
      return "Success." 
    end
      
    return "You are not an admin!"
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

end
