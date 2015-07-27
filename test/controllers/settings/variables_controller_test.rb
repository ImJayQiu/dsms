require 'test_helper'

class Settings::VariablesControllerTest < ActionController::TestCase
  setup do
    @settings_variable = settings_variables(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_variables)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_variable" do
    assert_difference('Settings::Variable.count') do
      post :create, settings_variable: { description: @settings_variable.description, fullname: @settings_variable.fullname, name: @settings_variable.name }
    end

    assert_redirected_to settings_variable_path(assigns(:settings_variable))
  end

  test "should show settings_variable" do
    get :show, id: @settings_variable
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_variable
    assert_response :success
  end

  test "should update settings_variable" do
    patch :update, id: @settings_variable, settings_variable: { description: @settings_variable.description, fullname: @settings_variable.fullname, name: @settings_variable.name }
    assert_redirected_to settings_variable_path(assigns(:settings_variable))
  end

  test "should destroy settings_variable" do
    assert_difference('Settings::Variable.count', -1) do
      delete :destroy, id: @settings_variable
    end

    assert_redirected_to settings_variables_path
  end
end
