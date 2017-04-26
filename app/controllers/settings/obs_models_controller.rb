class Settings::ObsModelsController < ApplicationController
  before_action :set_settings_obs_model, only: [:show, :edit, :update, :destroy]

  # GET /settings/obs_models
  # GET /settings/obs_models.json
  def index
    @settings_obs_models = Settings::ObsModel.all
  end

  # GET /settings/obs_models/1
  # GET /settings/obs_models/1.json
  def show
  end

  # GET /settings/obs_models/new
  def new
    @settings_obs_model = Settings::ObsModel.new
  end

  # GET /settings/obs_models/1/edit
  def edit
  end

  # POST /settings/obs_models
  # POST /settings/obs_models.json
  def create
    @settings_obs_model = Settings::ObsModel.new(settings_obs_model_params)

    respond_to do |format|
      if @settings_obs_model.save
        format.html { redirect_to @settings_obs_model, notice: 'Obs model was successfully created.' }
        format.json { render :show, status: :created, location: @settings_obs_model }
      else
        format.html { render :new }
        format.json { render json: @settings_obs_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/obs_models/1
  # PATCH/PUT /settings/obs_models/1.json
  def update
    respond_to do |format|
      if @settings_obs_model.update(settings_obs_model_params)
        format.html { redirect_to @settings_obs_model, notice: 'Obs model was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_obs_model }
      else
        format.html { render :edit }
        format.json { render json: @settings_obs_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/obs_models/1
  # DELETE /settings/obs_models/1.json
  def destroy
    @settings_obs_model.destroy
    respond_to do |format|
      format.html { redirect_to settings_obs_models_url, notice: 'Obs model was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_obs_model
      @settings_obs_model = Settings::ObsModel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_obs_model_params
      params.require(:settings_obs_model).permit(:name, :folder, :institute, :remark)
    end
end
