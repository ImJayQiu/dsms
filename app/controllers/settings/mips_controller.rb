class Settings::MipsController < ApplicationController
  before_action :set_settings_mip, only: [:show, :edit, :update, :destroy]

  # GET /settings/mips
  # GET /settings/mips.json
  def index
    @settings_mips = Settings::Mip.all
  end

  # GET /settings/mips/1
  # GET /settings/mips/1.json
  def show
  end

  # GET /settings/mips/new
  def new
    @settings_mip = Settings::Mip.new
  end

  # GET /settings/mips/1/edit
  def edit
  end

  # POST /settings/mips
  # POST /settings/mips.json
  def create
    @settings_mip = Settings::Mip.new(settings_mip_params)

    respond_to do |format|
      if @settings_mip.save
        format.html { redirect_to @settings_mip, notice: 'Mip was successfully created.' }
        format.json { render :show, status: :created, location: @settings_mip }
      else
        format.html { render :new }
        format.json { render json: @settings_mip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/mips/1
  # PATCH/PUT /settings/mips/1.json
  def update
    respond_to do |format|
      if @settings_mip.update(settings_mip_params)
        format.html { redirect_to @settings_mip, notice: 'Mip was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_mip }
      else
        format.html { render :edit }
        format.json { render json: @settings_mip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/mips/1
  # DELETE /settings/mips/1.json
  def destroy
    @settings_mip.destroy
    respond_to do |format|
      format.html { redirect_to settings_mips_url, notice: 'Mip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_mip
      @settings_mip = Settings::Mip.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_mip_params
      params.require(:settings_mip).permit(:name, :fullname, :description)
    end
end
