class Settings::ExperimentsController < ApplicationController
  before_action :set_settings_experiment, only: [:show, :edit, :update, :destroy]

  # GET /settings/experiments
  # GET /settings/experiments.json
  def index
    @settings_experiments = Settings::Experiment.all
  end

  # GET /settings/experiments/1
  # GET /settings/experiments/1.json
  def show
  end

  # GET /settings/experiments/new
  def new
    @settings_experiment = Settings::Experiment.new
  end

  # GET /settings/experiments/1/edit
  def edit
  end

  # POST /settings/experiments
  # POST /settings/experiments.json
  def create
    @settings_experiment = Settings::Experiment.new(settings_experiment_params)

    respond_to do |format|
      if @settings_experiment.save
        format.html { redirect_to @settings_experiment, notice: 'Experiment was successfully created.' }
        format.json { render :show, status: :created, location: @settings_experiment }
      else
        format.html { render :new }
        format.json { render json: @settings_experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/experiments/1
  # PATCH/PUT /settings/experiments/1.json
  def update
    respond_to do |format|
      if @settings_experiment.update(settings_experiment_params)
        format.html { redirect_to @settings_experiment, notice: 'Experiment was successfully updated.' }
        format.json { render :show, status: :ok, location: @settings_experiment }
      else
        format.html { render :edit }
        format.json { render json: @settings_experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/experiments/1
  # DELETE /settings/experiments/1.json
  def destroy
    @settings_experiment.destroy
    respond_to do |format|
      format.html { redirect_to settings_experiments_url, notice: 'Experiment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_experiment
      @settings_experiment = Settings::Experiment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_experiment_params
      params.require(:settings_experiment).permit(:name, :fullname, :description)
    end
end
