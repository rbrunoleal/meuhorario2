class RegistrationController < ApplicationController
  
  def record
  end
  
  def student_record
    redirect_to(new_students_path, info: 'Complete o cadastro.' )
  end
  
  def professor_record
    @user = current_user
    @professor = ProfessorUser.find_by(username: @user.username)
    if @professor.present?
      if @professor.approved
          ActiveRecord::Base.transaction do
          begin 
            @user.rule = "professor" 
            @user.enable = true
            @user.save!
            @professor.user = @user
            @professor.save!
            respond_to do |format|
              format.html { redirect_to painel_path, success: 'Acesso concluído.' }
            end
          rescue ActiveRecord::RecordInvalid => exception
            respond_to do |format|
             format.html { redirect_to registration_path, danger: 'Erro no cadastro, tente novamente.'}
            end
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to professor_users_new_access_path, info: 'Complete o cadastro.' }
      end
    end
  end
  
  def coordinator_record
    @user = current_user
    @coordinator = Coordinator.find_by(username: @user.username)
    if @coordinator.present?
      ActiveRecord::Base.transaction do
        begin 
          @user.rule = "coordinator"
          @user.enable = true
          @user.save!
          @coordinator.user = @user
          @coordinator.save!
          respond_to do |format|
            format.html { redirect_to painel_path, success: 'Acesso concluído.' }
          end
        rescue ActiveRecord::RecordInvalid => exception
          respond_to do |format|
           format.html { redirect_to registration_path, danger: 'Erro no cadastro, tente novamente.'}
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to registration_path, danger: 'Usuário não cadastrado com permissão de coordenador.' }
      end
    end
  end
end
