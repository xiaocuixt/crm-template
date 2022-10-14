class Users::SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    account = params[:user][:account].strip
    @user = User.where("email = :key OR mobile = :key", key: account).last
    if @user.blank?
      return redirect_to new_user_session_path, notice: "账号或密码错误!"
    end

    if @user.valid_password?(params[:user][:password])
      sign_in(:user, @user)
      super
    else
      return redirect_to new_user_session_path, notice: "账号或密码错误!"
    end
  end
end
