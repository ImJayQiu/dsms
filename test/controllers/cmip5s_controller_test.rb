require 'test_helper'

class Cmip5sControllerTest < ActionController::TestCase
  setup do
    @cmip5 = cmip5s(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cmip5s)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cmip5" do
    assert_difference('Cmip5.count') do
      post :create, cmip5: {  }
    end

    assert_redirected_to cmip5_path(assigns(:cmip5))
  end

  test "should show cmip5" do
    get :show, id: @cmip5
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cmip5
    assert_response :success
  end

  test "should update cmip5" do
    patch :update, id: @cmip5, cmip5: {  }
    assert_redirected_to cmip5_path(assigns(:cmip5))
  end

  test "should destroy cmip5" do
    assert_difference('Cmip5.count', -1) do
      delete :destroy, id: @cmip5
    end

    assert_redirected_to cmip5s_path
  end
end
