class Settings::IndsController < ApplicationController
  before_action :set_settings_ind, only: [:show, :edit, :update, :destroy]

  # GET /settings/inds
  # GET /settings/inds.json
  def index
    @settings_inds = Settings::Ind.all
  end

  # GET /settings/inds/1
  # GET /settings/inds/1.json
  def show
  end

  # GET /settings/inds/new
  def new
    @settings_ind = Settings::Ind.new
  end

  # GET /settings/inds/1/edit
  def edit
  end

  # POST /settings/inds
  # POST /settings/inds.json
  def create
    @settings_ind = Settings::Ind.new(settings_ind_params)

    respond_to do |format|
      if @settings_ind.save
        format.html { redirect_to @settings_ind, notice: 'Ind was successfully created.' }
        format.json { render :show, status: :created, location: @settings_ind }
      else
        format.html { render :new }
        format.json { render json: @settings_ind.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/inds/1
  # PATCH/PUT /settings/inds/1.json
  def update
    respond_to do |format|
      if @settings_ind.update(settings_ind_params)
        format.html { redirect_to @settings_ind, notice: 'Ind was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_ind }
      else
        format.html { render :edit }
        format.json { render json: @settings_ind.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/inds/1
  # DELETE /settings/inds/1.json
  def destroy
    @settings_ind.destroy
    respond_to do |format|
      format.html { redirect_to settings_inds_url, notice: 'Ind was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_ind
      @settings_ind = Settings::Ind.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_ind_params
      params.require(:settings_ind).permit(:name, :description, :remark)
    end
end
