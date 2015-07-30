class Settings::DatasetpathsController < ApplicationController
  before_action :set_settings_datasetpath, only: [:show, :edit, :update, :destroy]

  # GET /settings/datasetpaths
  # GET /settings/datasetpaths.json
  def index
    @settings_datasetpaths = Settings::Datasetpath.all
  end

  # GET /settings/datasetpaths/1
  # GET /settings/datasetpaths/1.json
  def show
  end

  # GET /settings/datasetpaths/new
  def new
    @settings_datasetpath = Settings::Datasetpath.new
  end

  # GET /settings/datasetpaths/1/edit
  def edit
  end

  # POST /settings/datasetpaths
  # POST /settings/datasetpaths.json
  def create
    @settings_datasetpath = Settings::Datasetpath.new(settings_datasetpath_params)

    respond_to do |format|
      if @settings_datasetpath.save
        format.html { redirect_to @settings_datasetpath, notice: 'Datasetpath was successfully created.' }
        format.json { render :show, status: :created, location: @settings_datasetpath }
      else
        format.html { render :new }
        format.json { render json: @settings_datasetpath.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/datasetpaths/1
  # PATCH/PUT /settings/datasetpaths/1.json
  def update
    respond_to do |format|
      if @settings_datasetpath.update(settings_datasetpath_params)
        format.html { redirect_to @settings_datasetpath, notice: 'Datasetpath was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_datasetpath }
      else
        format.html { render :edit }
        format.json { render json: @settings_datasetpath.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/datasetpaths/1
  # DELETE /settings/datasetpaths/1.json
  def destroy
    @settings_datasetpath.destroy
    respond_to do |format|
      format.html { redirect_to settings_datasetpaths_url, notice: 'Datasetpath was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_datasetpath
      @settings_datasetpath = Settings::Datasetpath.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_datasetpath_params
      params.require(:settings_datasetpath).permit(:name, :path, :remark)
    end
end
