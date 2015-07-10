require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  setup do
    @dataset = datasets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:datasets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dataset" do
    assert_difference('Dataset.count') do
      post :create, dataset: { category: @dataset.category, name: @dataset.name, remark: @dataset.remark, type1: @dataset.type1, type2: @dataset.type2 }
    end

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should show dataset" do
    get :show, id: @dataset
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dataset
    assert_response :success
  end

  test "should update dataset" do
    patch :update, id: @dataset, dataset: { category: @dataset.category, name: @dataset.name, remark: @dataset.remark, type1: @dataset.type1, type2: @dataset.type2 }
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should destroy dataset" do
    assert_difference('Dataset.count', -1) do
      delete :destroy, id: @dataset
    end

    assert_redirected_to datasets_path
  end
end
