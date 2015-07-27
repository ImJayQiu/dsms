class Settings::DatamodelsController < ApplicationController
  before_action :set_settings_datamodel, only: [:show, :edit, :update, :destroy]

  # GET /settings/datamodels
  # GET /settings/datamodels.json
  def index
    @settings_datamodels = Settings::Datamodel.all
  end

  # GET /settings/datamodels/1
  # GET /settings/datamodels/1.json
  def show
  end

  # GET /settings/datamodels/new
  def new
    @settings_datamodel = Settings::Datamodel.new
  end

  # GET /settings/datamodels/1/edit
  def edit
  end

  # POST /settings/datamodels
  # POST /settings/datamodels.json
  def create
    @settings_datamodel = Settings::Datamodel.new(settings_datamodel_params)

    respond_to do |format|
      if @settings_datamodel.save
        format.html { redirect_to @settings_datamodel, notice: 'Datamodel was successfully created.' }
        format.json { render :show, status: :created, location: @settings_datamodel }
      else
        format.html { render :new }
        format.json { render json: @settings_datamodel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/datamodels/1
  # PATCH/PUT /settings/datamodels/1.json
  def update
    respond_to do |format|
      if @settings_datamodel.update(settings_datamodel_params)
        format.html { redirect_to @settings_datamodel, notice: 'Datamodel was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_datamodel }
      else
        format.html { render :edit }
        format.json { render json: @settings_datamodel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/datamodels/1
  # DELETE /settings/datamodels/1.json
  def destroy
    @settings_datamodel.destroy
    respond_to do |format|
      format.html { redirect_to settings_datamodels_url, notice: 'Datamodel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_datamodel
      @settings_datamodel = Settings::Datamodel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_datamodel_params
      params.require(:settings_datamodel).permit(:name, :institute, :remark)
    end
end
