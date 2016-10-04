require 'test_helper'

class Settings::MipsControllerTest < ActionController::TestCase
  setup do
    @settings_mip = settings_mips(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_mips)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_mip" do
    assert_difference('Settings::Mip.count') do
      post :create, settings_mip: { description: @settings_mip.description, fullname: @settings_mip.fullname, name: @settings_mip.name }
    end

    assert_redirected_to settings_mip_path(assigns(:settings_mip))
  end

  test "should show settings_mip" do
    get :show, id: @settings_mip
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_mip
    assert_response :success
  end

  test "should update settings_mip" do
    patch :update, id: @settings_mip, settings_mip: { description: @settings_mip.description, fullname: @settings_mip.fullname, name: @settings_mip.name }
    assert_redirected_to settings_mip_path(assigns(:settings_mip))
  end

  test "should destroy settings_mip" do
    assert_difference('Settings::Mip.count', -1) do
      delete :destroy, id: @settings_mip
    end

    assert_redirected_to settings_mips_path
  end
end
