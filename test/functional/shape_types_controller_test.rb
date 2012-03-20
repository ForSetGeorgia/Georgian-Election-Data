require 'test_helper'

class ShapeTypesControllerTest < ActionController::TestCase
  setup do
    @shape_type = shape_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shape_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shape_type" do
    assert_difference('ShapeType.count') do
      post :create, shape_type: @shape_type.attributes
    end

    assert_redirected_to shape_type_path(assigns(:shape_type))
  end

  test "should show shape_type" do
    get :show, id: @shape_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @shape_type.to_param
    assert_response :success
  end

  test "should update shape_type" do
    put :update, id: @shape_type.to_param, shape_type: @shape_type.attributes
    assert_redirected_to shape_type_path(assigns(:shape_type))
  end

  test "should destroy shape_type" do
    assert_difference('ShapeType.count', -1) do
      delete :destroy, id: @shape_type.to_param
    end

    assert_redirected_to shape_types_path
  end
end
