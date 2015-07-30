class Settings::TemporalsController < ApplicationController
  before_action :set_settings_temporal, only: [:show, :edit, :update, :destroy]

  # GET /settings/temporals
  # GET /settings/temporals.json
  def index
    @settings_temporals = Settings::Temporal.all
  end

  # GET /settings/temporals/1
  # GET /settings/temporals/1.json
  def show
  end

  # GET /settings/temporals/new
  def new
    @settings_temporal = Settings::Temporal.new
  end

  # GET /settings/temporals/1/edit
  def edit
  end

  # POST /settings/temporals
  # POST /settings/temporals.json
  def create
    @settings_temporal = Settings::Temporal.new(settings_temporal_params)

    respond_to do |format|
      if @settings_temporal.save
        format.html { redirect_to @settings_temporal, notice: 'Temporal was successfully created.' }
        format.json { render :show, status: :created, location: @settings_temporal }
      else
        format.html { render :new }
        format.json { render json: @settings_temporal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/temporals/1
  # PATCH/PUT /settings/temporals/1.json
  def update
    respond_to do |format|
      if @settings_temporal.update(settings_temporal_params)
        format.html { redirect_to @settings_temporal, notice: 'Temporal was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_temporal }
      else
        format.html { render :edit }
        format.json { render json: @settings_temporal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/temporals/1
  # DELETE /settings/temporals/1.json
  def destroy
    @settings_temporal.destroy
    respond_to do |format|
      format.html { redirect_to settings_temporals_url, notice: 'Temporal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_temporal
      @settings_temporal = Settings::Temporal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_temporal_params
      params.require(:settings_temporal).permit(:name, :remark)
    end
end
