require 'test_helper'

class IndicatorScalesControllerTest < ActionController::TestCase
  setup do
    @indicator_scale = indicator_scales(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:indicator_scales)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create indicator_scale" do
    assert_difference('IndicatorScale.count') do
      post :create, indicator_scale: @indicator_scale.attributes
    end

    assert_redirected_to indicator_scale_path(assigns(:indicator_scale))
  end

  test "should show indicator_scale" do
    get :show, id: @indicator_scale.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @indicator_scale.to_param
    assert_response :success
  end

  test "should update indicator_scale" do
    put :update, id: @indicator_scale.to_param, indicator_scale: @indicator_scale.attributes
    assert_redirected_to indicator_scale_path(assigns(:indicator_scale))
  end

  test "should destroy indicator_scale" do
    assert_difference('IndicatorScale.count', -1) do
      delete :destroy, id: @indicator_scale.to_param
    end

    assert_redirected_to indicator_scales_path
  end
end
