require 'test_helper'

class Ecmwf::VarsControllerTest < ActionController::TestCase
  setup do
    @ecmwf_var = ecmwf_vars(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ecmwf_vars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ecmwf_var" do
    assert_difference('Ecmwf::Var.count') do
      post :create, ecmwf_var: { name: @ecmwf_var.name, remark: @ecmwf_var.remark, var: @ecmwf_var.var }
    end

    assert_redirected_to ecmwf_var_path(assigns(:ecmwf_var))
  end

  test "should show ecmwf_var" do
    get :show, id: @ecmwf_var
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ecmwf_var
    assert_response :success
  end

  test "should update ecmwf_var" do
    patch :update, id: @ecmwf_var, ecmwf_var: { name: @ecmwf_var.name, remark: @ecmwf_var.remark, var: @ecmwf_var.var }
    assert_redirected_to ecmwf_var_path(assigns(:ecmwf_var))
  end

  test "should destroy ecmwf_var" do
    assert_difference('Ecmwf::Var.count', -1) do
      delete :destroy, id: @ecmwf_var
    end

    assert_redirected_to ecmwf_vars_path
  end
end
