require 'test_helper'

class Ecmwf::TypesControllerTest < ActionController::TestCase
  setup do
    @ecmwf_type = ecmwf_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ecmwf_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ecmwf_type" do
    assert_difference('Ecmwf::Type.count') do
      post :create, ecmwf_type: { folder: @ecmwf_type.folder, name: @ecmwf_type.name, remark: @ecmwf_type.remark }
    end

    assert_redirected_to ecmwf_type_path(assigns(:ecmwf_type))
  end

  test "should show ecmwf_type" do
    get :show, id: @ecmwf_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ecmwf_type
    assert_response :success
  end

  test "should update ecmwf_type" do
    patch :update, id: @ecmwf_type, ecmwf_type: { folder: @ecmwf_type.folder, name: @ecmwf_type.name, remark: @ecmwf_type.remark }
    assert_redirected_to ecmwf_type_path(assigns(:ecmwf_type))
  end

  test "should destroy ecmwf_type" do
    assert_difference('Ecmwf::Type.count', -1) do
      delete :destroy, id: @ecmwf_type
    end

    assert_redirected_to ecmwf_types_path
  end
end
