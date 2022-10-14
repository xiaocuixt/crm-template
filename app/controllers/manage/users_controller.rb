module Manage
  class UsersController < Manage::BaseController
    before_action :get_user, only: [:edit, :update, :edit_password, :update_password]
    def index
      @users = User.includes(:roles).backend_search(keyword: params[:q]).order("users.created_at DESC")
        .paginate(page: params[:page], per_page: 100)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      respond_to do |format|
        if @user.save
          generate_user_roles
          @users = User.includes(:roles, :department, :user_group).order("users.created_at DESC").reload
          format.turbo_stream
          format.html { redirect_to manage_users_path, notice: "User was successfully updated." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
    end

    def update
      strong_params = params[:user][:password].present? ? user_params : no_password_params
      respond_to do |format|
        if @user.update strong_params
          generate_user_roles
          @users = User.includes(:roles, :department, :user_group).order("users.created_at DESC").reload
          format.turbo_stream
          format.html { redirect_to manage_users_path, notice: "User was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def edit_password
    end

    def update_password
      respond_to do |format|
        if @user.update params.require(:user).permit(:password, :password_confirmation)
          @users = User.includes(:roles, :department, :user_group).order("users.created_at DESC").reload
          format.turbo_stream
          format.html { redirect_to manage_users_path, notice: "User was successfully updated." }
        else
          format.html { render :edit_password, status: :unprocessable_entity }
        end
      end
    end

    # User profile
    def profile
    end

    def reset_password
      if params[:user][:password].blank?
        current_user.errors.add(:base, "Password can not be empty.")
        render :profile
        return
      end
  
      if params[:user][:password_confirmation].blank?
        current_user.errors.add(:base, "Password Confirmation can not be empty.")
        render :profile
        return
      end

      if params[:user][:password] != params[:user][:password_confirmation]
        current_user.errors.add(:base, "Passwords not match.")
        render :profile
        return
      end

      current_user.update(password: params[:user][:password])
      sign_out(current_user)

      redirect_to profile_manage_users_path
    end

    private
    def generate_user_roles
      role_ids = params[:role_ids]
      @user.user_roles.delete_all if @user.user_roles.present?

      if role_ids.present?
        role_ids.each do |role_id|
          @user.user_roles.where(role_id: role_id).first_or_create
        end
      end
    end

    def no_password_params
      params.require(:user).permit(:email, :mobile, user_roles_attributes: [:id, :role_id, :user_id, :_destroy])
    end

    def user_params
      params.require(:user).permit(:email, :mobile, :password, user_roles_attributes: [:id, :role_id, :user_id, :_destroy])
    end

    def get_user
      @user = User.find_by(id: params[:id])
    end
  end
end
