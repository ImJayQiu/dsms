require 'test_helper'

class Settings::ObsModelsControllerTest < ActionController::TestCase
  setup do
    @settings_obs_model = settings_obs_models(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_obs_models)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_obs_model" do
    assert_difference('Settings::ObsModel.count') do
      post :create, settings_obs_model: { folder: @settings_obs_model.folder, institute: @settings_obs_model.institute, name: @settings_obs_model.name, remark: @settings_obs_model.remark }
    end

    assert_redirected_to settings_obs_model_path(assigns(:settings_obs_model))
  end

  test "should show settings_obs_model" do
    get :show, id: @settings_obs_model
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_obs_model
    assert_response :success
  end

  test "should update settings_obs_model" do
    patch :update, id: @settings_obs_model, settings_obs_model: { folder: @settings_obs_model.folder, institute: @settings_obs_model.institute, name: @settings_obs_model.name, remark: @settings_obs_model.remark }
    assert_redirected_to settings_obs_model_path(assigns(:settings_obs_model))
  end

  test "should destroy settings_obs_model" do
    assert_difference('Settings::ObsModel.count', -1) do
      delete :destroy, id: @settings_obs_model
    end

    assert_redirected_to settings_obs_models_path
  end
end
