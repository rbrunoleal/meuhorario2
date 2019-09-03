class RegistrationController < ApplicationController
  
  #TRABALHAR COM TRANSACTION, ROOLBACK COM ERRO!
  
  def record
  end
  
  def student_record
    redirect_to(new_students_path)
  end
  
  def professor_record
    @user = current_user
    @professor = ProfessorUser.find_by(username: @user.username)
    respond_to do |format|
      if @professor.present?
        if @professor.aproved
          @user.rule = "professor" 
          @user.enable = true
          if @user.save
            @professor.user = @user
              if @professor.save
                format.html { redirect_to painel_path, notice: 'Acesso Concluído.' }
              else
                format.html { redirect_to registration_path, notice: 'Erro no Cadastro, Tente novamente.'}
              end
          end
        end
      else
        format.html { redirect_to professor_users_new_access_path }
      end
    end
  end
  
  def coordinator_record
    @user = current_user
    @coordinator = Coordinator.find_by(username: @user.username)
    respond_to do |format|
      if @coordinator.present?
        @user.rule = "coordinator"
        @user.enable = true
        if @user.save
          @coordinator.user = @user
          if @coordinator.save
             format.html { redirect_to painel_path, notice: 'Acesso Concluído.' }
          else 
             format.html { redirect_to registration_path, notice: 'Erro no Cadastro, Tente novamente.'}
          end
        end
      else
        format.html { redirect_to registration_path, notice: 'Usuario não Cadastrado com Permissão de Coordenador.' }
      end
    end
  end
  
end
