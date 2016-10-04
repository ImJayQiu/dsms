require 'test_helper'

class Settings::DatamodelsControllerTest < ActionController::TestCase
  setup do
    @settings_datamodel = settings_datamodels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_datamodels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_datamodel" do
    assert_difference('Settings::Datamodel.count') do
      post :create, settings_datamodel: { institute: @settings_datamodel.institute, name: @settings_datamodel.name, remark: @settings_datamodel.remark }
    end

    assert_redirected_to settings_datamodel_path(assigns(:settings_datamodel))
  end

  test "should show settings_datamodel" do
    get :show, id: @settings_datamodel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_datamodel
    assert_response :success
  end

  test "should update settings_datamodel" do
    patch :update, id: @settings_datamodel, settings_datamodel: { institute: @settings_datamodel.institute, name: @settings_datamodel.name, remark: @settings_datamodel.remark }
    assert_redirected_to settings_datamodel_path(assigns(:settings_datamodel))
  end

  test "should destroy settings_datamodel" do
    assert_difference('Settings::Datamodel.count', -1) do
      delete :destroy, id: @settings_datamodel
    end

    assert_redirected_to settings_datamodels_path
  end
end
