class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      reset_session
      remember @user
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      redirect_to new_user_path(@user, error_count: @user.errors.count,
                                       messages: @user.errors.full_messages)
    end
  end

  def edit
    @user = User.find(params[:id])
  end

    def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      redirect_to edit_user_path(@user, error_count: @user.errors.count,
                                       messages: @user.errors.full_messages)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
