class ProfessorUsersController < ApplicationController
  before_action :set_professor_user, only: [:edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authorize_professoruser

  def index
    @user = current_user
    @professor_users = ProfessorUser.all.select { |professor| professor.department.courses.include?(@user.coordinator.course) }
    @department = @user.coordinator.course.department_course.department.name
  end

  def edit
  end

  def new
    @professor_user = ProfessorUser.new
  end
  
  def table_professors
    @user = current_user
    @department = @user.coordinator.course.department_course.department.name
  end
  
  def complete_professors
    @user = current_user
    @result =  JSON.parse(params[:data_professor_users])
    ActiveRecord::Base.transaction do
      begin
        if(@result)
          @result.each do |r|
            @professor_user = ProfessorUser.find_by(username: r['usuario'].downcase)   
            if(!@professor_user)
              @professor_user = ProfessorUser.new(name: r['name'], username: r['usuario'].downcase)   
              @professor_user.department = @user.coordinator.course.department_course.department
              @professor_user.save!
            end
          end
        end
        respond_to do |format|
          format.html { redirect_to professor_users_path, success: 'Professores cadastrados.'}      
        end
      rescue ActiveRecord::RecordInvalid => exception
        respond_to do |format|
          format.html { redirect_to professor_users_path, danger: 'Erro ao salvar professor, tente novamente.' }
        end
      end
    end
  end
  
  def create
    @user = current_user
    @professor_user = ProfessorUser.new(professor_user_params)
    @professor_user.department = @user.coordinator.course.department_course.department
    respond_to do |format|
      if @professor_user.save
        format.html { redirect_to professor_users_path, success: 'Professor salvo.'}
      else
        format.html { render :new }
      end
    end
  end
  
  def destroy
    ActiveRecord::Base.transaction do
      @user = User.find_by(username: @professor_user.username)
      if @user
        @user.reset
        @user.save
      end
      @professor_user.destroy
    end
    respond_to do |format|
     format.html { redirect_to professor_users_url, success: 'Professor excluído.' }
    end
  end
  
  def update
    respond_to do |format|
      if @professor_user.update(professor_user_params)
        format.html { redirect_to professor_users_path, success: 'Professor salvo.'}
      else
        format.html { render :edit }
      end
    end
  end

  private
    def authorize_professoruser
      if @professor_user.present?
        authorize @professor_user
      else
        authorize ProfessorUser
      end
    end
    
    def set_professor_user
      @professor_user = ProfessorUser.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end
    
    def professor_user_params
      params.require(:professor_user).permit(:name, :username)
    end
end
