require 'test_helper'

class Settings::ExperimentsControllerTest < ActionController::TestCase
  setup do
    @settings_experiment = settings_experiments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_experiments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_experiment" do
    assert_difference('Settings::Experiment.count') do
      post :create, settings_experiment: { description: @settings_experiment.description, fullname: @settings_experiment.fullname, name: @settings_experiment.name }
    end

    assert_redirected_to settings_experiment_path(assigns(:settings_experiment))
  end

  test "should show settings_experiment" do
    get :show, id: @settings_experiment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_experiment
    assert_response :success
  end

  test "should update settings_experiment" do
    patch :update, id: @settings_experiment, settings_experiment: { description: @settings_experiment.description, fullname: @settings_experiment.fullname, name: @settings_experiment.name }
    assert_redirected_to settings_experiment_path(assigns(:settings_experiment))
  end

  test "should destroy settings_experiment" do
    assert_difference('Settings::Experiment.count', -1) do
      delete :destroy, id: @settings_experiment
    end

    assert_redirected_to settings_experiments_path
  end
end
