class UsersController < ApplicationController

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
    @user = User.find_by_id(params[:id])
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

  #GET /users/info
  def info
    @user = User.find_by_authentication_token(params[:authentication_token])

    respond_to do |format|
      format.json { render :show} 
    end
  end
end
