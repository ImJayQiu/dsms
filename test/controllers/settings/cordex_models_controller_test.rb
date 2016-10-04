require 'test_helper'

class Settings::CordexModelsControllerTest < ActionController::TestCase
  setup do
    @settings_cordex_model = settings_cordex_models(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_cordex_models)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_cordex_model" do
    assert_difference('Settings::CordexModel.count') do
      post :create, settings_cordex_model: { folder: @settings_cordex_model.folder, institute: @settings_cordex_model.institute, name: @settings_cordex_model.name, remark: @settings_cordex_model.remark }
    end

    assert_redirected_to settings_cordex_model_path(assigns(:settings_cordex_model))
  end

  test "should show settings_cordex_model" do
    get :show, id: @settings_cordex_model
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_cordex_model
    assert_response :success
  end

  test "should update settings_cordex_model" do
    patch :update, id: @settings_cordex_model, settings_cordex_model: { folder: @settings_cordex_model.folder, institute: @settings_cordex_model.institute, name: @settings_cordex_model.name, remark: @settings_cordex_model.remark }
    assert_redirected_to settings_cordex_model_path(assigns(:settings_cordex_model))
  end

  test "should destroy settings_cordex_model" do
    assert_difference('Settings::CordexModel.count', -1) do
      delete :destroy, id: @settings_cordex_model
    end

    assert_redirected_to settings_cordex_models_path
  end
end
