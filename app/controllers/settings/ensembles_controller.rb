class Settings::EnsemblesController < ApplicationController
  before_action :set_settings_ensemble, only: [:show, :edit, :update, :destroy]

  # GET /settings/ensembles
  # GET /settings/ensembles.json
  def index
    @settings_ensembles = Settings::Ensemble.all
  end

  # GET /settings/ensembles/1
  # GET /settings/ensembles/1.json
  def show
  end

  # GET /settings/ensembles/new
  def new
    @settings_ensemble = Settings::Ensemble.new
  end

  # GET /settings/ensembles/1/edit
  def edit
  end

  # POST /settings/ensembles
  # POST /settings/ensembles.json
  def create
    @settings_ensemble = Settings::Ensemble.new(settings_ensemble_params)

    respond_to do |format|
      if @settings_ensemble.save
        format.html { redirect_to @settings_ensemble, notice: 'Ensemble was successfully created.' }
        format.json { render :show, status: :created, location: @settings_ensemble }
      else
        format.html { render :new }
        format.json { render json: @settings_ensemble.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/ensembles/1
  # PATCH/PUT /settings/ensembles/1.json
  def update
    respond_to do |format|
      if @settings_ensemble.update(settings_ensemble_params)
        format.html { redirect_to @settings_ensemble, notice: 'Ensemble was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_ensemble }
      else
        format.html { render :edit }
        format.json { render json: @settings_ensemble.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/ensembles/1
  # DELETE /settings/ensembles/1.json
  def destroy
    @settings_ensemble.destroy
    respond_to do |format|
      format.html { redirect_to settings_ensembles_url, notice: 'Ensemble was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_ensemble
      @settings_ensemble = Settings::Ensemble.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_ensemble_params
      params.require(:settings_ensemble).permit(:name, :fullname, :description)
    end
end
