class ProfessorUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_professor_user, only: [:edit, :update, :destroy, :approved, :disapproved]

  def index
    @user = current_user
    @professor_users = ProfessorUser.all.select { |professor| professor.department.courses.include?(@user.coordinator.course) }
  end

  def edit
  end

  def new
    @professor_user = ProfessorUser.new
  end
  
  def new_access
    @professor_user = ProfessorUser.new
  end
  
  def create_access
    byebug
    @user = current_user
    @professor_user = ProfessorUser.new(professor_user_access_params)
    @professor_user.user = @user
    @professor_user.username = @user.username
    respond_to do |format|
      if @professor_user.save
        @user.enable = false
        @user.rule = "professor"
        if @user.save
          format.html { redirect_to root_path, notice: 'Acesso Concluído.' }
        else
          format.html { render :new }
        end      
      else
        format.html { render :new }
      end
    end
  end
  
  def create
    @professor_user = ProfessorUser.new(professor_user_params)
    @professor_user.department = current_user.coordinator.course.department_course.department
    @professor_user.approved = true
    respond_to do |format|
      if @professor_user.save
        format.html { redirect_to professor_users_path, sucess: 'Professor salvo.'}
      else
        format.html { render :new, danger: 'Erro ao salvar professor, tente novamente.' }
      end
    end
  end
  
  def destroy
    @professor_user.destroy
    respond_to do |format|
      format.html { redirect_to professor_users_url, notice: 'Professor excluido.' }
    end
  end
  
  def approved
    @professor_user.approved = true
    respond_to do |format|
      if @professor_user.save
        format.html { redirect_to professor_users_url, notice: 'Professor aprovado.' }
      else
        format.html { redirect_to professor_users_url, notice: 'Erro ao aprovar Professor.' }
      end
    end
  end
  
  def disapproved
    @professor_user.approved = false
    respond_to do |format|
      if @professor_user.save
        format.html { redirect_to professor_users_url, notice: 'Professor desaprovado.' }
      else
        format.html { redirect_to professor_users_url, notice: 'Erro ao desaprovar Professor.' }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @professor_user.update(professor_user_edit_params)
        format.html { redirect_to @professor_user }
      else
        format.html { render :edit }
      end
    end
  end

  private
    def set_professor_user
      @professor_user = ProfessorUser.find(params[:id])
    end

    def professor_user_access_params
      params.require(:professor_user).permit(:name, :department_id)
    end
    
    def professor_user_params
      params.require(:professor_user).permit(:name, :username)
    end
end
