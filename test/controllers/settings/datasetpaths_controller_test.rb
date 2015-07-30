require 'test_helper'

class Settings::DatasetpathsControllerTest < ActionController::TestCase
  setup do
    @settings_datasetpath = settings_datasetpaths(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_datasetpaths)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_datasetpath" do
    assert_difference('Settings::Datasetpath.count') do
      post :create, settings_datasetpath: { name: @settings_datasetpath.name, path: @settings_datasetpath.path, remark: @settings_datasetpath.remark }
    end

    assert_redirected_to settings_datasetpath_path(assigns(:settings_datasetpath))
  end

  test "should show settings_datasetpath" do
    get :show, id: @settings_datasetpath
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_datasetpath
    assert_response :success
  end

  test "should update settings_datasetpath" do
    patch :update, id: @settings_datasetpath, settings_datasetpath: { name: @settings_datasetpath.name, path: @settings_datasetpath.path, remark: @settings_datasetpath.remark }
    assert_redirected_to settings_datasetpath_path(assigns(:settings_datasetpath))
  end

  test "should destroy settings_datasetpath" do
    assert_difference('Settings::Datasetpath.count', -1) do
      delete :destroy, id: @settings_datasetpath
    end

    assert_redirected_to settings_datasetpaths_path
  end
end
