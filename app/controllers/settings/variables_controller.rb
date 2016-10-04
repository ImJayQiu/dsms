class Settings::VariablesController < ApplicationController
  before_action :set_settings_variable, only: [:show, :edit, :update, :destroy]

  # GET /settings/variables
  # GET /settings/variables.json
  def index
    @settings_variables = Settings::Variable.all
  end

  # GET /settings/variables/1
  # GET /settings/variables/1.json
  def show
  end

  # GET /settings/variables/new
  def new
    @settings_variable = Settings::Variable.new
  end

  # GET /settings/variables/1/edit
  def edit
  end

  # POST /settings/variables
  # POST /settings/variables.json
  def create
    @settings_variable = Settings::Variable.new(settings_variable_params)

    respond_to do |format|
      if @settings_variable.save
        format.html { redirect_to @settings_variable, notice: 'Variable was successfully created.' }
        format.json { render :show, status: :created, location: @settings_variable }
      else
        format.html { render :new }
        format.json { render json: @settings_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/variables/1
  # PATCH/PUT /settings/variables/1.json
  def update
    respond_to do |format|
      if @settings_variable.update(settings_variable_params)
        format.html { redirect_to @settings_variable, notice: 'Variable was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_variable }
      else
        format.html { render :edit }
        format.json { render json: @settings_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/variables/1
  # DELETE /settings/variables/1.json
  def destroy
    @settings_variable.destroy
    respond_to do |format|
      format.html { redirect_to settings_variables_url, notice: 'Variable was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_variable
      @settings_variable = Settings::Variable.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_variable_params
      params.require(:settings_variable).permit(:name, :fullname, :unit, :c_rate, :c_unit, :description)
    end
end
