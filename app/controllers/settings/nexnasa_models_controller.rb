class Settings::NexnasaModelsController < ApplicationController
  before_action :set_settings_nexnasa_model, only: [:show, :edit, :update, :destroy]

  # GET /settings/nexnasa_models
  # GET /settings/nexnasa_models.json
  def index
    @settings_nexnasa_models = Settings::NexnasaModel.all
  end

  # GET /settings/nexnasa_models/1
  # GET /settings/nexnasa_models/1.json
  def show
  end

  # GET /settings/nexnasa_models/new
  def new
    @settings_nexnasa_model = Settings::NexnasaModel.new
  end

  # GET /settings/nexnasa_models/1/edit
  def edit
  end

  # POST /settings/nexnasa_models
  # POST /settings/nexnasa_models.json
  def create
    @settings_nexnasa_model = Settings::NexnasaModel.new(settings_nexnasa_model_params)

    respond_to do |format|
      if @settings_nexnasa_model.save
        format.html { redirect_to @settings_nexnasa_model, notice: 'Nexnasa model was successfully created.' }
        format.json { render :show, status: :created, location: @settings_nexnasa_model }
      else
        format.html { render :new }
        format.json { render json: @settings_nexnasa_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/nexnasa_models/1
  # PATCH/PUT /settings/nexnasa_models/1.json
  def update
    respond_to do |format|
      if @settings_nexnasa_model.update(settings_nexnasa_model_params)
        format.html { redirect_to @settings_nexnasa_model, notice: 'Nexnasa model was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_nexnasa_model }
      else
        format.html { render :edit }
        format.json { render json: @settings_nexnasa_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/nexnasa_models/1
  # DELETE /settings/nexnasa_models/1.json
  def destroy
    @settings_nexnasa_model.destroy
    respond_to do |format|
      format.html { redirect_to settings_nexnasa_models_url, notice: 'Nexnasa model was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_nexnasa_model
      @settings_nexnasa_model = Settings::NexnasaModel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_nexnasa_model_params
      params.require(:settings_nexnasa_model).permit(:name, :folder, :institute, :remark)
    end
end
