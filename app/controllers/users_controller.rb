class UsersController < ApplicationController
  before_filter :authenticate
  before_action :set_user, only: [:lock, :unlock, :destroy, :reset]
  
  def index
    @users = User.order(:username)
    
    @search = {username: ""}
    if(params.has_key?(:search))
      if params[:user_username].present?
        @users = @users.select { |user| user.username.include? params[:user_username] }
      end
      @search = {username: params[:user_username]}
    end
  end
  
  def lock
    @user.locked_at = Time.now
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, success: 'Bloqueio realizado.' }
      else
        format.html { redirect_to users_path, danger: 'Erro ao bloquear usuário, tente novamente.' }
      end
    end
  end
  
  def unlock
    @user.locked_at = ""
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, success: 'Desbloqueio realizado.' }
      else
        format.html { redirect_to users_path, danger: 'Erro ao desbloquear usuário, tente novamente.' }
      end
    end
  end
  
  def reset
    @user.reset
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, success: 'Usuário resetado.' }
      else
        format.html { redirect_to users_path, danger: 'Erro ao resetar usuário, tente novamente.' }
      end
    end
  end
  
  def destroy
    @user.destroy
    respond_to do |format|
     format.html { redirect_to users_path, success: 'Usuário excluído.' }
    end
  end
  
  private
    def set_user
      @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end
  
  protected
    def authenticate
      if Rails.env.production?
        authenticate_or_request_with_http_basic do |username, password|
          username == ENV["ADMIN_USERNAME"] && password == ENV["ADMIN_PASSWORD"]
        end
      end
    end
end
