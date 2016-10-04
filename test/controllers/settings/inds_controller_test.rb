require 'test_helper'

class Settings::IndsControllerTest < ActionController::TestCase
  setup do
    @settings_ind = settings_inds(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_inds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_ind" do
    assert_difference('Settings::Ind.count') do
      post :create, settings_ind: { description: @settings_ind.description, name: @settings_ind.name, remark: @settings_ind.remark }
    end

    assert_redirected_to settings_ind_path(assigns(:settings_ind))
  end

  test "should show settings_ind" do
    get :show, id: @settings_ind
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_ind
    assert_response :success
  end

  test "should update settings_ind" do
    patch :update, id: @settings_ind, settings_ind: { description: @settings_ind.description, name: @settings_ind.name, remark: @settings_ind.remark }
    assert_redirected_to settings_ind_path(assigns(:settings_ind))
  end

  test "should destroy settings_ind" do
    assert_difference('Settings::Ind.count', -1) do
      delete :destroy, id: @settings_ind
    end

    assert_redirected_to settings_inds_path
  end
end
