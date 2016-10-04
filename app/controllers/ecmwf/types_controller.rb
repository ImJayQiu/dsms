class Ecmwf::TypesController < ApplicationController
  before_action :set_ecmwf_type, only: [:show, :edit, :update, :destroy]

  # GET /ecmwf/types
  # GET /ecmwf/types.json
  def index
    @ecmwf_types = Ecmwf::Type.all
  end

  # GET /ecmwf/types/1
  # GET /ecmwf/types/1.json
  def show
  end

  # GET /ecmwf/types/new
  def new
    @ecmwf_type = Ecmwf::Type.new
  end

  # GET /ecmwf/types/1/edit
  def edit
  end

  # POST /ecmwf/types
  # POST /ecmwf/types.json
  def create
    @ecmwf_type = Ecmwf::Type.new(ecmwf_type_params)

    respond_to do |format|
      if @ecmwf_type.save
        format.html { redirect_to @ecmwf_type, notice: 'Type was successfully created.' }
        format.json { render :show, status: :created, location: @ecmwf_type }
      else
        format.html { render :new }
        format.json { render json: @ecmwf_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ecmwf/types/1
  # PATCH/PUT /ecmwf/types/1.json
  def update
    respond_to do |format|
      if @ecmwf_type.update(ecmwf_type_params)
        format.html { redirect_to @ecmwf_type, notice: 'Type was successfully updated.' }
        format.json { render :show, status: :ok, location: @ecmwf_type }
      else
        format.html { render :edit }
        format.json { render json: @ecmwf_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ecmwf/types/1
  # DELETE /ecmwf/types/1.json
  def destroy
    @ecmwf_type.destroy
    respond_to do |format|
      format.html { redirect_to ecmwf_types_url, notice: 'Type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ecmwf_type
      @ecmwf_type = Ecmwf::Type.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ecmwf_type_params
      params.require(:ecmwf_type).permit(:name, :folder, :remark)
    end
end
