require 'test_helper'

class Settings::TemporalsControllerTest < ActionController::TestCase
  setup do
    @settings_temporal = settings_temporals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings_temporals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settings_temporal" do
    assert_difference('Settings::Temporal.count') do
      post :create, settings_temporal: { name: @settings_temporal.name, remark: @settings_temporal.remark }
    end

    assert_redirected_to settings_temporal_path(assigns(:settings_temporal))
  end

  test "should show settings_temporal" do
    get :show, id: @settings_temporal
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settings_temporal
    assert_response :success
  end

  test "should update settings_temporal" do
    patch :update, id: @settings_temporal, settings_temporal: { name: @settings_temporal.name, remark: @settings_temporal.remark }
    assert_redirected_to settings_temporal_path(assigns(:settings_temporal))
  end

  test "should destroy settings_temporal" do
    assert_difference('Settings::Temporal.count', -1) do
      delete :destroy, id: @settings_temporal
    end

    assert_redirected_to settings_temporals_path
  end
end
