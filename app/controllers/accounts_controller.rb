class AccountsController < ApplicationController
  def index
    @accounts = Account.includes(:skills, :interests).all
  end

  def new
    @account = Users::Create.new
    @skills = Skill.all
    @interests = Interest.all
  end

  def create
    outcome = Users::Create.run(params[:account])

    if outcome.valid?
      redirect_to accounts_path, notice: 'User created successfully'
    else
      @user = outcome
      @skills = Skill.all
      @interests = Interest.all

      respond_to do |format|
        format.html { render 'new', status: :unprocessable_entity }

        format.turbo_stream do
          render turbo_stream:
                   turbo_stream.update('forms_errors',
                                       partial: 'shared/errors',
                                       locals:   { object: @user })
        end
      end
    end
  end
end