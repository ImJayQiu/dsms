class Ecmwf::VarsController < ApplicationController
  before_action :set_ecmwf_var, only: [:show, :edit, :update, :destroy]

  # GET /ecmwf/vars
  # GET /ecmwf/vars.json
  def index
    @ecmwf_vars = Ecmwf::Var.all
  end

  # GET /ecmwf/vars/1
  # GET /ecmwf/vars/1.json
  def show
  end

  # GET /ecmwf/vars/new
  def new
    @ecmwf_var = Ecmwf::Var.new
  end

  # GET /ecmwf/vars/1/edit
  def edit
  end

  # POST /ecmwf/vars
  # POST /ecmwf/vars.json
  def create
    @ecmwf_var = Ecmwf::Var.new(ecmwf_var_params)

    respond_to do |format|
      if @ecmwf_var.save
        format.html { redirect_to @ecmwf_var, notice: 'Var was successfully created.' }
        format.json { render :show, status: :created, location: @ecmwf_var }
      else
        format.html { render :new }
        format.json { render json: @ecmwf_var.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ecmwf/vars/1
  # PATCH/PUT /ecmwf/vars/1.json
  def update
    respond_to do |format|
      if @ecmwf_var.update(ecmwf_var_params)
        format.html { redirect_to @ecmwf_var, notice: 'Var was successfully updated.' }
        format.json { render :show, status: :ok, location: @ecmwf_var }
      else
        format.html { render :edit }
        format.json { render json: @ecmwf_var.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ecmwf/vars/1
  # DELETE /ecmwf/vars/1.json
  def destroy
    @ecmwf_var.destroy
    respond_to do |format|
      format.html { redirect_to ecmwf_vars_url, notice: 'Var was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ecmwf_var
      @ecmwf_var = Ecmwf::Var.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ecmwf_var_params
      params.require(:ecmwf_var).permit(:name, :var, :remark)
    end
end
