class UsersController < ApplicationController

  skip_before_filter :after_token_authentication, :only => :register

  #put /users/register
  def register
    user = User.new(user_params)
    user.encrypted_password = ::BCrypt::Password.create("#{params[:user][:password]}#{user.class.pepper}", cost: user.class.stretches).to_s
    user.isApproved = false
    puts user.encrypted_password

    if user.save
      render :json=> user.as_json(:auth_token=>user.authentication_token, :username=>user.username), :status=>201
      return
    else
      warden.custom_failure!
      render :json=> user.errors, :status=>422
    end
  end

  
  #PATCH /users/:userid/approve
  def approve
    approving_user = User.find_by_authentication_token(params[:authentication_key])
    if approving_user == nil
        render :status => :unauthorized, :json=>{:message=>"Supply admin token."}
        return
    end

    if !approving_user.isAdmin
      render :status => :unauthorized, :json=>{:message=>"Approving user is not an admin."}
      return
    end
    

    u = User.find_by_id(params[:userid])
    u.isApproved = true
    u.save!
    render :nothing => true, :status => :ok
  end



  #DELETE /users/:userid/reject
  def reject
    rejecting_user = User.find_by_authentication_token(params[:authentication_key])
    if rejecting_user == nil
        render :status => :unauthorized, :json=>{:message=>"Supply admin token."}
        return
    end

    if !rejecting_user.isAdmin
      render :status => :unauthorized, :json=>{:message=>"Rejecting user is not an admin."}
      return
    end

    u = User.find_by_id(params[:userid])
    u.destroy!
    render :status => :ok
  end


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

  #GET /users.json
  def index
    if params[:approved] == nil
      @users = User.all
    elsif params[:approved] == "true"
      @users = User.where(:isApproved => true)
    elsif params[:approved] == "false"
      @users = User.where(:isApproved => false)
    end
  end

  def show
    @user = User.find_by_id(params[:id])
    unless @user == current_user
      render status: :unauthorized
    end
  end

  #GET /users/info
  def info
    @user = User.find_by_authentication_token(params[:authentication_key])
    if @user == nil
      render :status=>400, :json=>{:message=>"Invalid token."}
      return
    end

    respond_to do |format|
      format.json { render :show} 
    end
  end

  private 

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :password)
  end
end
