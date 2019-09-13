class RegistrationController < ApplicationController
  
  def record
  end
  
  def student_record
    redirect_to(new_students_path)
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
              format.html { redirect_to painel_path, notice: 'Acesso Concluído.' }
            end
          rescue ActiveRecord::RecordInvalid => exception
            respond_to do |format|
             format.html { redirect_to registration_path, notice: 'Erro no Cadastro, '+ exception.message + ' Tente novamente.'}
            end
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to registration_path, notice: 'Usuario não Cadastrado com Permissão de Coordenador.' }
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
            format.html { redirect_to painel_path, notice: 'Acesso Concluído.' }
          end
        rescue ActiveRecord::RecordInvalid => exception
          respond_to do |format|
           format.html { redirect_to registration_path, notice: 'Erro no Cadastro, '+ exception.message + ' Tente novamente.'}
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to registration_path, notice: 'Usuario não Cadastrado com Permissão de Coordenador.' }
      end
    end
  end
end
