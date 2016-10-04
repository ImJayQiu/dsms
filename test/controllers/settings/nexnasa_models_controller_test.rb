require 'test_helper'

class Settings::NexnasaModelsControllerTest < ActionController::TestCase
  setup do
    @settings_nexnasa_model = settings_nexnasa_models(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_nexnasa_models)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_nexnasa_model" do
    assert_difference('Settings::NexnasaModel.count') do
      post :create, settings_nexnasa_model: { folder: @settings_nexnasa_model.folder, institute: @settings_nexnasa_model.institute, name: @settings_nexnasa_model.name, remark: @settings_nexnasa_model.remark }
    end

    assert_redirected_to settings_nexnasa_model_path(assigns(:settings_nexnasa_model))
  end

  test "should show settings_nexnasa_model" do
    get :show, id: @settings_nexnasa_model
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_nexnasa_model
    assert_response :success
  end

  test "should update settings_nexnasa_model" do
    patch :update, id: @settings_nexnasa_model, settings_nexnasa_model: { folder: @settings_nexnasa_model.folder, institute: @settings_nexnasa_model.institute, name: @settings_nexnasa_model.name, remark: @settings_nexnasa_model.remark }
    assert_redirected_to settings_nexnasa_model_path(assigns(:settings_nexnasa_model))
  end

  test "should destroy settings_nexnasa_model" do
    assert_difference('Settings::NexnasaModel.count', -1) do
      delete :destroy, id: @settings_nexnasa_model
    end

    assert_redirected_to settings_nexnasa_models_path
  end
end
