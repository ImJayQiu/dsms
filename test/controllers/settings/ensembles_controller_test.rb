require 'test_helper'

class Settings::EnsemblesControllerTest < ActionController::TestCase
  setup do
    @settings_ensemble = settings_ensembles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_ensembles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_ensemble" do
    assert_difference('Settings::Ensemble.count') do
      post :create, settings_ensemble: { description: @settings_ensemble.description, fullname: @settings_ensemble.fullname, name: @settings_ensemble.name }
    end

    assert_redirected_to settings_ensemble_path(assigns(:settings_ensemble))
  end

  test "should show settings_ensemble" do
    get :show, id: @settings_ensemble
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_ensemble
    assert_response :success
  end

  test "should update settings_ensemble" do
    patch :update, id: @settings_ensemble, settings_ensemble: { description: @settings_ensemble.description, fullname: @settings_ensemble.fullname, name: @settings_ensemble.name }
    assert_redirected_to settings_ensemble_path(assigns(:settings_ensemble))
  end

  test "should destroy settings_ensemble" do
    assert_difference('Settings::Ensemble.count', -1) do
      delete :destroy, id: @settings_ensemble
    end

    assert_redirected_to settings_ensembles_path
  end
end
