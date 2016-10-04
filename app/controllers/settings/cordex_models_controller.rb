class Settings::CordexModelsController < ApplicationController
  before_action :set_settings_cordex_model, only: [:show, :edit, :update, :destroy]

  # GET /settings/cordex_models
  # GET /settings/cordex_models.json
  def index
    @settings_cordex_models = Settings::CordexModel.all
  end

  # GET /settings/cordex_models/1
  # GET /settings/cordex_models/1.json
  def show
  end

  # GET /settings/cordex_models/new
  def new
    @settings_cordex_model = Settings::CordexModel.new
  end

  # GET /settings/cordex_models/1/edit
  def edit
  end

  # POST /settings/cordex_models
  # POST /settings/cordex_models.json
  def create
    @settings_cordex_model = Settings::CordexModel.new(settings_cordex_model_params)

    respond_to do |format|
      if @settings_cordex_model.save
        format.html { redirect_to @settings_cordex_model, notice: 'Cordex model was successfully created.' }
        format.json { render :show, status: :created, location: @settings_cordex_model }
      else
        format.html { render :new }
        format.json { render json: @settings_cordex_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/cordex_models/1
  # PATCH/PUT /settings/cordex_models/1.json
  def update
    respond_to do |format|
      if @settings_cordex_model.update(settings_cordex_model_params)
        format.html { redirect_to @settings_cordex_model, notice: 'Cordex model was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_cordex_model }
      else
        format.html { render :edit }
        format.json { render json: @settings_cordex_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/cordex_models/1
  # DELETE /settings/cordex_models/1.json
  def destroy
    @settings_cordex_model.destroy
    respond_to do |format|
      format.html { redirect_to settings_cordex_models_url, notice: 'Cordex model was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_cordex_model
      @settings_cordex_model = Settings::CordexModel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_cordex_model_params
      params.require(:settings_cordex_model).permit(:name, :folder, :institute, :remark)
    end
end
